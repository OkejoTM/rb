class SeoTemplate::Presenter < BasicPresenter
  extend Memoist

  delegate :count, to: :properties, prefix: true

  class << self
    # Возвращает сео-шаблон в соответствии с переданными параметрами и slug
    # @param slug [String] slug сео-шаблона
    # @param location_presenter [Location::Presenter] локация, для которой искать сео шаблон
    # @param property_supertype [Integer] идентификатор категории недвижимости
    # @return [SeoTemplate::Presenter]
    def by_params_with_slug(slug:, location_presenter: nil, property_supertype: nil)
      if location_presenter.present?
        SeoTemplate::Presenter.new(
            location_presenter.seo_templates.find_by(slug: slug),
            location_presenter
        )
      else
        SeoTemplate::Presenter.new(
            SeoTemplate.find_by(template_location_type: SeoTemplate::TYPE_WORLD,
                                property_supertype_id: property_supertype,
                                slug: slug)
        )
      end
    end

    # Возвращает базовый сео-шаблон в соответствии с переданными параметрами
    # @param slug [String] slug сео-шаблона
    # @param location_presenter [Location::Presenter] локация, для которой искать сео шаблон
    # @param property_supertype [Integer] идентификатор категории недвижимости
    # @return [SeoTemplate::Presenter]
    def default_by_params(location_type: nil, location_presenter: nil, property_supertype: nil)
      if property_supertype.present?
        SeoTemplate::Presenter.new(SeoTemplate.default_by_property_supertype(property_supertype))
      else
        SeoTemplate::Presenter.new(SeoTemplate.default_by_location_type(location_type), location_presenter)
      end
    end

    # Возвращает сео-шаблон в соответствии с переданными параметрами
    # если передан slug, то поиск происходит с его учетом,
    # иначе поиск среди базовых сео-шаблонов
    # @param slug [String] slug сео-шаблона
    # @param location_presenter [Location::Presenter] локация, для которой искать сео шаблон
    # @param property_supertype [Integer] идентификатор категории недвижимости
    # @return [SeoTemplate::Presenter]
    def by_params(slug: nil, location_presenter: nil, property_supertype: nil, location_type: nil)
      if slug.present?
        SeoTemplate::Presenter.by_params_with_slug(slug: slug,
                                                   location_presenter: location_presenter,
                                                   property_supertype: property_supertype)
      else
        SeoTemplate::Presenter.default_by_params(location_type: location_type,
                                                 location_presenter: location_presenter,
                                                 property_supertype: property_supertype)
      end
    end
  end

  def initialize(seo_template, area = nil)
    super(seo_template)
    @area = area
  end

  # Ссылки на другие сео-шаблоны локации (или данного супертипа)
  # @return [Array<Hash>] - :name - наименование ссылки.
  #                  :link - ссылка на сео страницу.
  def similar_links
    get_links_from_templates(similar_templates)
  end

  # Ссылки на другие сео-шаблоны локации (или данного супертипа), сгруппированные по группам сео шаблонов
  # @return [Hash<String, Array<Hash>>] - ссылки на сео страницы, сгруппированные по группам сео шаблонов
  # @option opts [String] - заголовок группы сео шаблонов (ссылок)
  # @option opts [Array<Hash>] - список ссылок
  # @option opts [String] :name - наименование ссылки.
  # @option opts [String] :link - ссылка на сео страницу.
  def similar_links_by_groups
    result = {}
    other_links = []

    seo_template_groups = SeoTemplatesGroup.all.to_a

    similar_templates.group_by(&:seo_templates_group_id).each do |group_id, templates|
      seo_template_group = seo_template_groups.select { |elem| elem.id == group_id }.first

      templates_links = get_links_from_templates(templates)

      if templates_links.count > 0
        if seo_template_group&.is_active?
          result[seo_template_group.title] = get_links_from_templates(templates)
        else
          other_links.concat(get_links_from_templates(templates))
        end
      end
    end

    # Помещаем "прочее" в конец, если имеются такие ссылки
    result[I18n.t('common.other')] = other_links if other_links.present?
    result
  end

  # Заголовок блока с сео ссылками
  # @return [String]
  def internal_links_title
    I18n.t("filter.internal_links_header", area_locative: @area&.title_prepositional)
  end

  memoize :similar_links, :internal_links_title

  private

    # Похожие сео-шаблоны
    # Если у сео-шаблона есть локация, то похожие сео-шаблоны только для этой локации,
    # иначе это сео-шаблон для супертипа, то похожие сео-шаблоны для супертипа текущего сео-шаблона
    def similar_templates
      templates =
        if @area.present?
          @area.seo_templates
        else
          SeoTemplate.where(template_location_type: SeoTemplate::TYPE_WORLD,
                            property_supertype_id: property_supertype_id)
        end

      templates.preload(:seo_location_pages).where.not(id: self.id)#.secondary
    end


    # Список ссылок и их заголовков из заданных сео шаблонов
    # @return [Array<Hash>] - :name - наименование ссылки.
    #                  :link - ссылка на сео страницу.
    def get_links_from_templates(templates)
      result = []

      templates.each do |template|
        page = template.get_seo_page(@area)
        if page.active?
          result << { name: "#{page.link_name} (#{page.properties_count})",
                      link: "#{page.seo_path}" }
        end
      end

      result
    end
end

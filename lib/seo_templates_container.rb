# @TODO: сделать сео страницы и выпилить
class SeoTemplatesContainer

  def initialize(seo_template)
    @seo_template = seo_template
  end

  # Список всех относительных ссылок для текущей локали, в которых используется сео шаблон
  # @return [Array<String>]
  def seo_paths
    active_pages.map(&:seo_path)
  end

  # Презентеры для всех активных (с активной недвижимостью) страниц сео шаблона
  # @return [Array<SeoPage::Presenter>]
  def active_pages
    all_pages.select { |page| page.try(:active?) }
  end

  # Презентеры для всех страниц сео шаблона
  # @return [Array<SeoPage::Presenter>]
  def all_pages
    locations = @seo_template.locations
    locations = locations.visible if locations.present?

    if locations.present?
      locations.map { |l| SeoPage::Presenter.new(@seo_template.get_seo_page(l), wrap_location(l)) }
    else
      [SeoPage::Presenter.new(@seo_template.get_seo_page)]
    end
  end

  private
    def wrap_location(l)
      if l.instance_of?(Country)
        Country::Presenter.new(l)
      elsif l.instance_of?(Region)
        Region::Presenter.new(l)
      elsif l.instance_of?(City)
        City::Presenter.new(l)
      else
        l
      end
    end
end

class Parsers::Vartur::Pages::PropertyPage
  include ActiveModel::Validations

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call(property_urls)
    property_urls.each do |urls|
      begin
        # Загружаем обе версии страницы
        en_page = load_property_page(urls[:en])
        ru_page = load_property_page(urls[:ru])

        if en_page.blank? || ru_page.blank?
          @logger.warn("Пропущена #{urls[:en]} т.к. ответ был пустым")
          next
        end

        # Парсим данные с обеих страниц
        en_attrs = parse_page(en_page, :en)
        ru_attrs = parse_page(ru_page, :ru)

        # Объединяем атрибуты
        property_attrs = merge_attributes(en_attrs, ru_attrs)
        next if property_attrs.blank?

        process_parsed(urls[:en], property_attrs)
      rescue => e
        @logger.error("Ошибка при парсинге. #{urls[:en]}\n#{e.message}\n#{e.backtrace.first}\n")
        false
      end
    end
  end

  private

    def attribute_parser_map
      {
        en: {
          h1_en: :h1,
          pictures: :pictures,
          country_name_en: :country_name_en,
          region_en: :region,
          city_en: :city,
          property_type_en: :property_type,
          bathroom_count: :bathroom_count,
          area: :area,
          building_year: :building_year,
          room_count: :room_count,
          bedroom_count: :bedroom_count,
          sale_price: :sale_price,
          description_en: :description,
          area_unit: :area_unit,
          parsed: :parsed,
          moderated: :moderated
        },
        ru: {
          h1_ru: :h1,
          country_name_ru: :country_name_ru,
          region_ru: :region,
          city_ru: :city,
          property_type_ru: :property_type,
          description_ru: :description
        }
      }
    end

    def load_property_page(property_url)
      @agent.load_page(property_url)
    end

    def parse_page(page, locale)
      parse_attributes(page, locale)
    end

    def merge_attributes(en_attrs, ru_attrs)
      en_attrs.merge(ru_attrs)
    end

    def property_upsert
      @property_upsert = Parsers::Vartur::Operations::Property::Upsert.new
    end

    def process_parsed(property_url, attrs)
      handler = property_upsert
      result = handler.call(property_url, attrs)

      if handler.errors.present?
        @logger.error(handler.errors.full_messages)
      else
        entity = handler.entity
        new_or_updated = entity.new_record? ? 'добавлена' : 'изменена'
        @logger.info("Сущность #{entity.id} была #{new_or_updated}")
        @logger.info("Переданные параметры: #{attrs}")
      end

      result
    end

    def parse_attributes(page, map_path)
      parsed_hash = {}
      handler = Parsers::Vartur::Attributes::PropertyAttributes.new(page)
      method_list =
        if map_path.is_a? Array
          attribute_parser_map.dig(*map_path)
        else
          attribute_parser_map[map_path]
        end
      method_list.each do |attribute, method|
        parsed_hash[attribute] = handler.public_send(method)
      end
      parsed_hash
    end
end

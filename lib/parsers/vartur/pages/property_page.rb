class Parsers::Vartur::Pages::PropertyPage < Parsers::BasePage
  include ActiveModel::Validations

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call(property_urls)
    return false unless valid?
    property_urls.each do |url|
      begin
        @logger.info("Старт парсинга недвижимости #{url}\n")
        property_attrs = parse_pages(url)

        next if property_attrs.blank?

        handler = Parsers::Vartur::Operations::Property::Upsert.new
        process_parsed(handler, property_attrs, identifier: url)
      rescue => e
        @logger.error("Ошибка при парсинге. #{url}\n#{e.message}\n#{e.backtrace.first}\n")
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

  def parse_pages(url)
    # Загружаем обе версии страницы
    en_page = load_property_page(url)
    ru_page = load_property_page(url.gsub(%r{/listings/(\d+)$}, '/ru/spiski/\1'))

    if en_page.blank? || ru_page.blank?
      @logger.warn("Пропущена #{url} т.к. ответ был пустым")
      return nil
    end

    # Парсим данные с обеих страниц
    en_attrs = parse_attributes(en_page, :en, Parsers::Vartur::Attributes::PropertyAttributes)
    ru_attrs = parse_attributes(ru_page, :ru, Parsers::Vartur::Attributes::PropertyAttributes)

    # Объединяем атрибуты
    en_attrs.merge(ru_attrs)
  end
end

class Parsers::Vartur::Pages::PropertyPage < Parsers::BasePage
  include ActiveModel::Validations

  attr_reader :agent, :logger, :agency

  validates :agent, presence: true
  validates :logger, presence: true
  validates :agency, presence: true

  def initialize(agent, logger, agency)
    @agent = agent
    @logger = logger
    @agency = agency
  end

  def call(property_urls)
    return false unless valid?
    success = true
    property_urls.each do |url|
      begin
        @logger.info("Старт парсинга недвижимости #{url}\n")
        property_attrs = parse_pages(url)

        next if property_attrs.blank?

        success &= process_parsed(url, property_attrs)
      rescue => e
        @logger.error("Ошибка при парсинге. #{url}\n#{e.message}\n#{e.backtrace.first}\n")
        success = false
      end
    end
    success
  end

  private

    def attribute_parser_map
      @attribute_parser_map ||=
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
      en_page = @agent.load_page(url)
      ru_page = @agent.load_page(url.gsub(%r{/listings/(\d+)$}, '/ru/spiski/\1'))

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

    def process_parsed(property_url, attrs)
      handler = Parsers::Vartur::Operations::Property::Upsert.new(@agency)
      success = handler.call(property_url, attrs)

      if success
        result = handler.result
        new_or_updated = result.previously_new_record? ? 'добавлена' : 'изменена'
        @logger.info("Сущность #{result.id} была #{new_or_updated}")
        @logger.info("Переданные параметры: #{attrs}")
      else
        @logger.error(handler.errors.full_messages)
      end
      success
    end
end

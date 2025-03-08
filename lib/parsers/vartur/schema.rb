class Parsers::Vartur::Schema
  include ActiveModel::Validations

  AGENCY_URL = 'www.vartur.com'

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call
    return false unless valid?

    begin
      # agency = parse_agency_info(AGENCY_URL)
      property_urls = parse_property_links
      new_properties, existed_property_urls = *separate_properties(property_urls)
      deactivate_not_founded_properties(AGENCY_URL, existed_property_urls)
      log_separated_properties(new_properties, existed_property_urls)
      parse_properties(property_urls, AGENCY_URL)

      true
    rescue => e
      errors.add(:base, e.message)
      false
    end
  end

  private

    def parse_agency_info(agency_url)
      Parsers::Vartur::Pages::AgencyPage.new(agent, logger).call(agency_url)
    rescue => e
      raise 'Ошибка во время парсинга страниц агентства'
    end

    def parse_property_links
      Parsers::Vartur::Pages::SearchPage.new(agent, logger).call
    rescue => e
      raise 'Ошибка во время парсинга страницы поиска агентства'
    end

    def separate_properties(property_urls)
      en_urls = property_urls.to_a.pluck(:en)

      existing_properties =
        ::Property
          .where(external_link: en_urls)
          .pluck(:external_link)

      new_properties = property_urls.reject { |urls| urls[:en].in?(existing_properties) }

      [new_properties, existing_properties]
    rescue => e
      raise 'Ошибка при разделении недвижимостей'
    end

    def deactivate_not_founded_properties(agency_url, existed_property_urls)
      en_urls = existed_property_urls.to_a.pluck(:en)

      ::Property
        .parsed
        .joins(:agency)
        .where('agencies.parse_source': agency_url)
        .where.not(external_link: en_urls)
        .update_all(is_active: false)
    rescue => e
      raise 'Ошибка при деактивации старых недвижимостей'
    end

    def log_separated_properties(new_property_urls, existed_property_urls)
      separated_properties_info =
        "Новых недвижимостей: #{new_property_urls.count}. Существующих недвижимостей: #{existed_property_urls.count}"
      logger.info(separated_properties_info)
    end

    def parse_properties(property_urls, agency_url)
      property_page_parser = Parsers::Vartur::Pages::PropertyPage.new(agent, logger)
      property_page_parser.call(property_urls)
      logger.info('Парсинг завершен')
    rescue => e
      raise 'Ошибка во время парсинга недвижимостей'
    end
end

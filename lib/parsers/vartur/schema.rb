class Parsers::Vartur::Schema
  include ActiveModel::Validations

  AGENCY_URL = 'www.vartur.com'
  LOCALES = %i[en ru].freeze

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
      parse_agency_info(AGENCY_URL)
      property_urls = parse_property_links
      new_properties, existed_property_urls = *separate_properties(property_urls)
      deactivate_not_founded_properties(AGENCY_URL, existed_property_urls)
      log_separated_properties(new_properties, existed_property_urls)
      parse_properties(property_urls)

      true
    rescue => e
      errors.add(:base, e.message)
      logger.error("Произошла ошибка во время парсинга: #{e.message}")
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
      search_page = Parsers::Vartur::Pages::SearchPage.new(agent, logger)
      search_page.call
      search_page.result
    rescue => e
      raise 'Ошибка во время парсинга страницы поиска агентства'
    end

    def separate_properties(property_urls)
      existing_properties =
        ::Property
          .where(external_link: property_urls)
          .pluck(:external_link)

      new_properties = property_urls.reject { |urls| urls.in?(existing_properties) }

      [new_properties, existing_properties]
    rescue => e
      raise 'Ошибка при разделении недвижимостей'
    end

    def deactivate_not_founded_properties(agency_url, existed_property_urls)
      ::Property
        .parsed
        .joins(:agency)
        .where('agencies.parse_source': agency_url)
        .where.not(external_link: existed_property_urls)
        .update_all(is_active: false)
    rescue => e
      raise 'Ошибка при деактивации старых недвижимостей'
    end

    def log_separated_properties(new_property_urls, existed_property_urls)
      separated_properties_info =
        "Новых недвижимостей: #{new_property_urls.count}. Существующих недвижимостей: #{existed_property_urls.count}"
      logger.info(separated_properties_info)
    end

    def parse_properties(property_urls)
      agency = ::Agency
                 .select(:id, :website, :parse_source)
                 .where('website=:link', link: Parsers::ParserUtils.wrap_url(AGENCY_URL))
                 .first

      if agency.nil?
        raise "Не удалось найти агентство с URL #{AGENCY_URL}"
      end

      property_page_parser = Parsers::Vartur::Pages::PropertyPage.new(agent, logger, agency)
      property_page_parser.call(property_urls)
      logger.info('Парсинг завершен')
    rescue => e
      raise "Ошибка во время парсинга недвижимостей: #{e.message}"
    end
end

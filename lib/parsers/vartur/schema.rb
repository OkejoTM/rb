class Parsers::Vartur::Schema
  include ActiveModel::Validations

  AGENCY_URL = 'www.vartur.com'
  LOCALES = %i[en ru].freeze

  attr_reader :agent, :logger, :agency

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

      existed_property_urls = load_existed_property_urls(property_urls)
      new_properties = determine_new_property_urls(property_urls, existed_property_urls)

      deactivate_not_founded_properties(AGENCY_URL, existed_property_urls)
      log_separated_properties(new_properties, existed_property_urls)
      parse_properties(property_urls)

      true
    rescue => e
      errors.add(:base, e.message)
      logger.error("Произошла ошибка во время парсинга: #{e.message}\n#{e.backtrace.join("\n")}")
      false
    end
  end

  private

    def parse_agency_info(agency_url)
      handler = Parsers::Vartur::Pages::AgencyPage.new(agent, logger)
      success = handler.call(agency_url)
      @agency = handler.agency

      unless success
        raise "Парсинг страниц агентства завершился с ошибками"
      end
      success
    end

    def parse_property_links
      search_page = Parsers::Vartur::Pages::SearchPage.new(agent, logger)
      success = search_page.call
      unless success
        raise "Ошибка во время парсинга страницы поиска агентства"
      end

      search_page.result
    end

    def load_existed_property_urls(property_urls)
      ::Property
        .where(external_link: property_urls)
        .pluck(:external_link)
    end

    def determine_new_property_urls(external_property_urls, existing_property_urls)
      external_property_urls - existing_property_urls
    end

    def deactivate_not_founded_properties(agency_url, existed_property_urls)
      ::Property
        .parsed
        .joins(:agency)
        .where('agencies.parse_source': agency_url)
        .where.not(external_link: existed_property_urls)
        .update_all(is_active: false)
    end

    def log_separated_properties(new_property_urls, existed_property_urls)
      separated_properties_info =
        "Новых недвижимостей: #{new_property_urls.count}. Существующих недвижимостей: #{existed_property_urls.count}"
      logger.info(separated_properties_info)
    end

    def parse_properties(property_urls)

      property_page_parser = Parsers::Vartur::Pages::PropertyPage.new(agent, logger, @agency)
      success = property_page_parser.call(property_urls)

      unless success
        raise "Парсинг недвижимостей завершился с ошибками"
      end

      logger.info('Парсинг завершен')
    end
end

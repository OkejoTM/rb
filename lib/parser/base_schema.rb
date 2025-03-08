class Parser::BaseSchema
  extend Messegable

  include Dry::Transaction

  attr_reader :agent, :logger

  define_message :parse_finished, 'Парсинг завершен'
  define_message :parse_error, 'Ошибка во время парсинга недвижимостей'
  define_message :separated_properties_info, 'Новых недвижимостей %i. Существующих недвижимостей: %i'
  define_message :separating_properties_error, 'Ошибка при разделении недвижимостей'
  define_message :deactivating_properties_error, 'Ошибка при деактивации старых недвижимостей'
  define_message :search_page_properties_error, 'Ошибка во время парсинга страницы поиска агентства'
  define_message :agency_page_properties_error, 'Ошибка во время парсинга страниц агентства'

  def initialize(agent:, logger:)
    super
    @agent = agent
    @logger = logger
  end

  # обдумать перенос
  def log_separated_properties(new_property_urls:, existed_property_urls:, **rest)
    @logger.info(separated_properties_info(new_property_urls.count, existed_property_urls.count))
  end
end

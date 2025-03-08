class Parser::Pages::WebType::BaseAgencyPage < Parser::BasePage
  include Parser::ParserUtils

  define_message :error_property_parse,
                 "Ошибка при парсинге агентства %s.\n %s\n %s\n"
  define_message :entity_saved,
                 "Агентство %s было %s"
  define_message :save_failure,
                 "Невозможно сохранить агентство %s\n Ошибки: %s"
  define_message :operation_failure,
                 "Ошибка при создании или обновлении агентства %s\n%s\n%s"

  def call(agency_url, agency_handler: nil)
    agency_attrs = {}

    page = load_agency_page(agency_url)

    if page.blank?
      if agency_handler.present? && !agency_handler.new?
        process_parsed(
          agency_handler,
          { is_active: false },
          identifier: agency_url
        )
      end
      @logger.warn(empty_response(URI.decode(agency_url)))
      return agency_attrs
    end

    agency_attrs = parse_page(page)

    process_parsed(
      agency_handler,
      agency_attrs,
      identifier: agency_url
    )

  rescue => e
    @logger.error(error_property_parse(agency_url, e.message, e.backtrace.join("\n")))
    agency_attrs
  end

  # Первоначальная загрузка страницы агентства
  # @param [String] agency_url
  # @return [Mechanaize::Page]
  def load_agency_page(agency_url)
    raise NotImplementedError
  end

  # Парсит страницу, делает различные манипляции для получения хэша сущности агентства
  # @param [Mechanaize::Page] page
  # @return [Hash]
  def parse_page(page)
    raise NotImplementedError
  end
end

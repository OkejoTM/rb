class Parser::Pages::WebType::BasePropertyPage < Parser::BasePage

  define_message :error_property_parse,
                 "Ошибка при парсинге недвижимости: %s\n %s\n %s\n"
  define_message :entity_saved,
                 "Недвижимость %s была %s"
  define_message :save_failure,
                 "Невозможно сохранить недвижимость %s\n Ошибки: %s"
  define_message :operation_failure,
                 "Ошибка при создании или обновлении недвижимости %s\n%s\n%s"
  define_message :empty_response,
                 "Пропущена %s т.к. ответ был пустым"


  def call(property_urls, property_handler: nil)
    property_urls.each do |property_url|

      page = load_property_page(property_url)

      if page.blank?
        if property_handler.present? && !property_handler.new?
          process_parsed(
            property_handler,
            { is_active: false, external_link: property_url },
            identifier: property_url
          )
        end
        @logger.warn(empty_response(URI.decode(property_url)))
        next
      end

      new_property = parse_page(page)

      next if property_handler.blank? || new_property.blank?

      process_parsed(
        property_handler,
        new_property,
        identifier: property_url
      )

    rescue StandardError => e
      @logger.error(error_property_parse(property_url, e.message, e.backtrace.join("\n")))
    end
  end

  # Парсит страницу, делает различные манипляции для получения хэша сущности недвижимости
  # @param [Mechanaize::Page] page
  # @return [Hash]
  def parse_page(page)
    raise NotImplementedError
  end

  # Первоначальная загрузка страницы недвижимости
  # @param [String] property_url
  # @return [Mechanaize::Page]
  def load_property_page(property_url)
    raise NotImplementedError
  end
end

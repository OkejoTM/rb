class Parser::Pages::FileType::BasePropertyPage < Parser::BasePage
  include Parser::FileTypeParser

  define_message :error_property_parse,
                 "Ошибка при парсинге недвижимости.\n %s\n %s\n"
  define_message :entity_saved,
                 "Недвижимость %s была %s"
  define_message :save_failure,
                 "Невозможно сохранить недвижимость %s\n Ошибки: %s"
  define_message :operation_failure,
                 "Ошибка при создании или обновлении недвижимости %s\n%s\n%s"

  def call(file, urls, property_handler: nil)
    call!(file, urls, property_handler: property_handler)
  rescue => e
    @logger.error(error_property_parse(e.message, e.backtrace.join("\n")))
  ensure
    file.rewind # "Rewind time!"(c) (обнуляет курсор файла)
  end

  def call!(file, identifiers, property_handler: nil)

    xml_iterator(file) do |parsed_node|
      current_property = parsed_property(parsed_node)
      identifier = identifier_field(current_property)

      # для разделения недвижимостей которые нужно создать или отредактировать
      next unless identifiers.any? { |u| u == identifier }

      process_parsed(
        property_handler,
        current_property,
        identifier: identifier
      )
    end

  end

  # Возвращает поле по которому определяется к какой группе относится недвижимость к новым или старым
  # @param [Hash] parsed_property Распарсенная по полям недвижимость
  # @return String
  def identifier_field(parsed_property)
    raise NotImplementedError
  end

  # Парсит недвижимость
  # @param [Nokogiri::XmlNode] parsed_node
  # @return [Hash]
  def parsed_property(parsed_node)
    raise NotImplementedError
  end
end

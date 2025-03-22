class Parsers::BasePage
  extend Messegable

  define_message :error_property_parse,
                 "Ошибка при парсинге. %s\n %s\n"
  define_message :entity_saved,
                 "Сущность %s была %s"
  define_message :save_failure,
                 "Невозможно сохранить сущность %s\n Ошибки: %s"
  define_message :operation_failure,
                 "Ошибка при создании или обновлении сущности %s\n%s\n%s"
  define_message :params_dump,
                 "Переданные параметры: %s"
  define_message :empty_response,
                 "Пропущена %i, %s т.к. ответ был пустым"

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call(input)
    raise NotImplementedError
  end

  protected

    def parser_class
      raise NotImplementedError
    end

    # запускает методы в контексте класса, в соответствии с +attribute_parser_map+
    # @param [Mechanize::Response] page страница для парсинга
    # @param [Symbol|Array<Symbol>] map_path локаль для выбора или путь к методам
    # @param [Object] attributes_class класс парсера
    def parse_attributes(page, map_path, attributes_class)
      parsed_hash = {}
      handler = attributes_class.new(page)
      method_list =
        if map_path.is_a? Array
          attribute_parser_map.dig(*map_path)
        else
          attribute_parser_map[map_path]
        end

      method_list.each do |attribute, method|
        parsed_hash[attribute] = handler.send(method)
      end
      parsed_hash
    end

    def attribute_parser_map
      {}
    end

    # @param [Parser::Operation::Base] handler Операция, сохраняющая сущность в БД
    # @param [Hash] attrs параметры передаваемые в операцию.
    # @param [Hash] rest дополнительные параметры
    # @options identifier - уникальная строка для сущности при парсинге (url недвижимости/агентства, offer-id)
    def process_parsed(handler, attrs, **rest)
      return attrs if handler.blank?

      handler.call(attrs) do |m|
        m.success do |entity|
          new_or_updated = handler.new? ? 'добавлена' : 'изменена'
          @logger.info(entity_saved(entity.id, new_or_updated))
          @logger.info(params_dump(attrs))
        end

        m.failure :save do |error|
          @logger.error(save_failure(rest[:identifier], error[:errors]))
        end

        m.failure do |error|
          if error.is_a? String
            @logger.error(error)
          else
            backtrace = error[:exception].backtrace.join("\n")
            @logger.error(operation_failure(rest[:identifier], error[:message], backtrace))
            @logger.info(params_dump(attrs))
          end
        end
      end
    end
end

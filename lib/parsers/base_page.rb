class Parsers::BasePage

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
end

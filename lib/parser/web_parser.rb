module Parser
  class WebParser
    extend Messegable

    define_message :parse_start, 'Парсинг %s начат с %s'
    define_message :parse_success, 'Парсинг успешно завершен'
    define_message :parse_process_finish, 'Парсинг полностью завершен'
    define_message :parse_process_start, 'Парсинг запущен'
    define_message :exception_template, "%s:\n %s\n%s"

    def initialize(proxy: nil)
      @proxy = proxy
      initialize_mechanize_agent
      initialize_logger
    end

    # @param [Object] parsing_schema_class Схема, которая управляет парсингом, наследник класса BaseSchema
    # @param [Object] attrs
    # agencies_filter_url: 'https://prian.ru/company'
    def parse(parsing_schema_class, **attrs)
      @logger.info(parse_start(parsing_schema_class, attrs))

      parsing_schema_class
        .new(agent: @agent, logger: @logger)
        .call(attrs) do |m|
          m.success do
            @logger.info(parse_success)
          end

          m.failure do |error|
            @logger.error(
              exception_template(error[:message], error[:exception].message, error[:exception].backtrace.join("\n"))
            )
          end
        end
    end

    def parse_links(links)
      @logger.info(parse_process_start)
      grouped = Parser::SchemaChooser.separate_by_domain(links)

      grouped.each do |domain, links_of_domain|
        schema = Parser::SchemaChooser.get_schema_by_domain(domain)

        links_of_domain.each do |link|

          initialize_mechanize_agent
          parse(schema, agency_url: link)

        end
      end

      @logger.info(parse_process_finish)
    end

    private
      def initialize_mechanize_agent
        @agent = AgentProxy.new(proxy: @proxy)
      end

      def initialize_logger
        log_out =
          if Rails.env.development?
            STDOUT
          else
            Rails.root.join('log', 'parser.log')
          end
        logger_type =
          if PropimoSettings.on?('send_parser_errors')
            Parser::RollbarLogger
          else
            Logger
          end
        @logger = logger_type.new(log_out)
      end
  end
end

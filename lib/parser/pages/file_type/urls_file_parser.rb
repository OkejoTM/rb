class Parser::Pages::FileType::UrlsFileParser < Parser::BasePage
  include Parser::FileTypeParser

  define_message :warn_matcher_field_nil,
                 "Недвижимость пропущена. +matcher_field+ вернул nil"

  def initialize(agent, logger)
    @matchers = [] # элементы по котором будут сравниваться между собой недвижимости новые и старые

    super(agent, logger)
  end

  def call(file)
    begin
      call!(file)
    rescue => e
      @logger.error(error_property_parse(e.message, e.backtrace.join("\n")))
    ensure
      file.rewind # "Rewind time!"(c) (обнуляет курсор файла)
    end

    @matchers
  end

  def call!(file)
    xml_iterator(file) do |property_node|
      matcher = matcher_field(property_node)

      if matcher.blank?
        @logger.warn(warn_matcher_field_nil)
        next
      end

      @matchers.push(matcher)
    end

    @matchers
  end

  protected
    # Возвращает строку по которой в дальнейшем будут отличаться недвижимости в методе
    # +Parser::Pages::FileType::BasePropertyPage#identifier_field+
    # @param [Nokogiri::XmlNode] property_node
    # @return [String]
    def matcher_field(property_node)
      raise NotImplementedError
    end
end

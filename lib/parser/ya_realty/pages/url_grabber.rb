class Parser::YaRealty::Pages::UrlGrabber < Parser::Pages::FileType::UrlsFileParser

  protected

    def parser_class
      Parser::YaRealty::Attributes::PropertyAttributes
    end

    def matcher_field(property_node)
      parsed = parser_class.new(property_node)
      parsed.grabber_link
    end

    def property_node?(node)
      node.name == 'url'
    end
end

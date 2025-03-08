class Parser::PortugalEstate::Pages::UrlGrabber < Parser::Pages::FileType::UrlsFileParser

  protected

    def matcher_field(property_node)
      parsed = parser_class.new(property_node)
      parsed.external_link
    end

    def parser_class
      Parser::PortugalEstate::Attributes::PropertyAttributes
    end

    def property_node?(node)
      node.name == 'Row'
    end
end

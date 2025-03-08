class Parser::DevCentrum::Pages::IdGrabber < Parser::Pages::FileType::UrlsFileParser

  protected

    def parser_class
      Parser::DevCentrum::Attributes::PropertyAttributes
    end

    def matcher_field(property_node)
      parsed = parser_class.new(property_node)
      parsed.unique_id
    end

    def property_node?(node)
      node.name == 'id'
    end
end

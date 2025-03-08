module Parser
  # Содержит в себе интерфейс и основные методы-шаги при парсинге файла XML типа, загружаемого по ссылке
  module FileTypeSchema
    def load_xml_file(agency_url:)
      download = open(agency_url) # saves file to /tmp

      Success(file: download, xml_url: agency_url)
    end

    def parse_urls(file:, xml_url:)
      urls = url_grabber.call(file)

      { file: file, urls: urls, xml_url: xml_url }
    end

    def url_grabber
      raise NotImplementedError
    end

    def deactivate_not_founded_properties(file:, urls:, xml_url:)
      properties = Property
        .parsed
        .joins(:agency)
        .select(:'agencies.parse_source', :is_active, :external_link, :id)
        .where('agencies.parse_source': xml_url)

      properties_for_update = properties.where(external_link: urls).pluck(:external_link)
      properties_for_create = urls - properties_for_update

      properties_for_deactivate = properties.where.not(external_link: urls)
      properties_for_deactivate.update_all(is_active: false)

      {
        file: file,
        new_property_urls: properties_for_create,
        existed_property_urls: properties_for_update,
        xml_url: xml_url,
      }
    end

    def parse_properties(file:, new_property_urls:, existed_property_urls:, xml_url:)
      property_creator = Parser::Operation::Property::Create
                           .preload(
                             agency_where_cond: [parse_source: xml_url]
                           )

      property_parser.call(file, new_property_urls, property_handler: property_creator)

      property_updater = Parser::Operation::Property::Update
                           .preload(
                             property_where_cond: [external_link: existed_property_urls]
                           )

      property_parser.call(file, existed_property_urls, property_handler: property_updater)

      Success(file: file)
    end

    def property_parser
      raise NotImplementedError
    end

    def remove_xml_file(file:)
      File.delete(file) if File.exist?(file)
      Success(parse_finished)
    end
  end
end

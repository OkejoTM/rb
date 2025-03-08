module Parser
  # Содержит в себе интерфейс и основные методы-шаги при парсинге сайта
  module WebTypeSchema
    def agency_page_parser
      raise NotImplementedError
    end

    def parse_agency_info(agency_url:)
      existing_agency = Agency.find_by(website: agency_url)

      agency_handler =
        if existing_agency.present?
          # обновляем
          Parser::Operation::Agency::Update.preload(agency_where_cond: [website: agency_url])
        else
          # Создаем новое
          Parser::Operation::Agency::Create.new
        end

      agency_page_parser.call(agency_url, agency_handler: agency_handler)

      Success(agency_url: agency_url)
    rescue => e
      Failure(exception: e, message: agency_page_properties_error)
    end

    def search_page_parser
      raise NotImplementedError
    end

    def parse_property_links(agency_url:)
      property_urls = search_page_parser.call

      Success(property_urls: property_urls, agency_url: agency_url)
    rescue => e
      Failure(exception: e, message: search_page_properties_error)
    end

    def property_page_parser
      raise NotImplementedError
    end

    def separate_properties(property_urls:, **rest)
      # Недвижимости чьи url были получены через парсинг
      existing_properties = Property
        .where(external_link: property_urls)
        .pluck(:external_link)

      new_properties = property_urls - existing_properties

      Success(new_property_urls: new_properties, existed_property_urls: existing_properties, **rest)
    rescue => e
      Failure(exception: e, message: separating_properties_error)
    end

    def deactivate_not_founded_properties(agency_url:, existed_property_urls:, **rest)
      Property
        .parsed
        .joins(:agency)
        .where('agencies.parse_source': agency_url)
        .where.not(external_link: existed_property_urls)
        .update_all(is_active: false)

      Success(
          agency_url: agency_url,
          existed_property_urls: existed_property_urls,
          **rest
      )
    rescue => e
      Failure(exception: e, message: deactivating_properties_error)
    end

    def parse_properties(new_property_urls:, existed_property_urls:, agency_url:, **rest)
      property_creator = Parser::Operation::Property::Create
        .preload(
          agency_where_cond: ['prian_link=:link OR website=:link', link: agency_url]
        )

      property_page_parser.call(new_property_urls, property_handler: property_creator)

      property_updater = Parser::Operation::Property::Update
        .preload(
          property_where_cond: [external_link: existed_property_urls]
        )

      property_page_parser.call(existed_property_urls, property_handler: property_updater)

      Success(parse_finished)
    rescue => e
      Failure(exception: e, message: parse_error)
    end
  end
end

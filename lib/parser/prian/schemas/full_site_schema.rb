class Parser::Prian::Schemas::FullSiteSchema < Parser::BaseSchema
  include Parser::WebTypeSchema

  define_message :parse_search_error, 'Ошибка во время парсинга страницы фильтра'
  define_message :separate_agencies_error, 'Ошибка при разделении агентств'
  define_message :separated_agencies_info, 'Новых агентств %i. Существующих агентств: %i'
  define_message :parse_agencies_error, 'Ошибка во время парсинга страниц агентств'

  # Parse agency-links from agencies search-page
  step :parse_search_page
  step :separate_agencies
  tee :log_separated_agencies

  # Parse agencies information and properties links
  step :parse_agencies
  step :separate_properties
  step :deactivate_not_founded_properties
  tee :log_separated_properties

  # Parse properties information
  step :parse_properties

  def parse_search_page(agencies_filter_url:)
    agency_urls = Parser::Prian::Pages::SearchPage
                    .new(@agent, @logger)
                    .call(agencies_filter_url)

    Success(agency_urls: agency_urls)
  rescue => e
    Failure(exception: e, message: parse_search_error)
  end

  def separate_agencies(agency_urls:)
    existing_agencies = Agency.where(prian_link: agency_urls)
                              .pluck(:prian_link)

    new_agencies = agency_urls - existing_agencies

    Success(new_agency_urls: new_agencies, existed_agency_urls: existing_agencies)
  rescue => e
    Failure(exception: e, message: separate_agencies_error)
  end

  def log_separated_agencies(new_agency_urls:, existed_agency_urls:)
    @logger.info(separated_agencies_info(new_agency_urls.count, existed_agency_urls.count))
  end

  def parse_agencies(new_agency_urls:, existed_agency_urls:)
    agency_page_parser = Parser::Prian::Pages::AgencyPage.new(@agent, @logger)

    agency_creator = Parser::Operation::Agency::Create.new

    # Ссылки на недвижимости, из новых агентств
    property_urls_new = agency_page_parser.call(new_agency_urls, agency_handler: agency_creator)

    agency_updater = Parser::Operation::Agency::Update.preload(agency_where_cond: [prian_link: existed_agency_urls])

    # Ссылки на недвижимости из доступных парсеру агентств
    property_urls_existing_agencies = agency_page_parser.call(existed_agency_urls, agency_handler: agency_updater)

    # Т.к. как в новых, так и в старых агентствах могут быть недвижимости которые необходимо обновить, скрепляем их
    Success(property_urls: property_urls_new.concat(property_urls_existing_agencies),
            agency_urls: new_agency_urls + existed_agency_urls)
  rescue => e
    Failure(exception: e, message: parse_agencies_error)
  end

  def parse_properties(new_property_urls:, existed_property_urls:, agency_urls:)
    return Success(parse_finished) if new_property_urls.blank? && existed_property_urls.blank?

    property_page_parser = Parser::Prian::Pages::PropertyPage.new(@agent, @logger)

    property_creator = Parser::Operation::Property::Create
      .preload(agency_where_cond: [prian_link: agency_urls])

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

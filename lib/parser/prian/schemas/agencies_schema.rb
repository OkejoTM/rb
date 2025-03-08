class Parser::Prian::Schemas::AgenciesSchema < Parser::Prian::Schemas::FullSiteSchema
  # Separate agency-links from agencies search-page
  step :parse_agency_info

  # Parse agencies information and properties links
  step :separate_properties
  step :deactivate_not_founded_properties
  tee :log_separated_properties

  # Parse properties information
  step :parse_properties

  def parse_agency_info(agency_url:)
    existing_agency = Agency.find_by(prian_link: agency_url)

    agency_handler =
        if existing_agency.present?
          # обновляем
          Parser::Operation::Agency::Update.preload(agency_where_cond: [prian_link: agency_url])
        else
          # Создаем новое
          Parser::Operation::Agency::Create.new
        end

    property_urls = agency_page_parser.call([agency_url], agency_handler: agency_handler)

    Success(agency_url: agency_url, property_urls: property_urls)
  rescue => e
    Failure(exception: e, message: agency_page_properties_error)
  end

  def agency_page_parser
    Parser::Prian::Pages::AgencyPage.new(@agent, @logger)
  end

  def parse_properties(new_property_urls:, existed_property_urls:, agency_url:)
    super(
      new_property_urls: new_property_urls,
      existed_property_urls: existed_property_urls,
      agency_urls: [agency_url]
    )
  end
end

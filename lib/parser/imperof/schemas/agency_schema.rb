class Parser::Imperof::Schemas::AgencySchema < Parser::BaseSchema
  include Parser::WebTypeSchema

  step :parse_agency_info
  step :parse_property_links
  step :separate_properties
  step :deactivate_not_founded_properties
  tee :log_separated_properties
  step :parse_properties

  def agency_page_parser
    Parser::Imperof::Pages::AgencyPage.new(@agent, @logger)
  end

  def search_page_parser
    Parser::Imperof::Pages::SearchPage.new(@agent, @logger)
  end

  def property_page_parser
    Parser::Imperof::Pages::PropertyPage.new(@agent, @logger)
  end
end

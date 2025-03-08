class Parser::DevCentrum::Schemas::PropertiesSchema < Parser::BaseSchema
  include Parser::FileTypeSchema

  step :load_xml_file
  map :parse_urls
  map :deactivate_not_founded_properties
  tee :log_separated_properties
  step :parse_properties
  map :remove_xml_file

  def url_grabber
    Parser::DevCentrum::Pages::IdGrabber.new(@agent, @logger)
  end

  def property_parser
    Parser::DevCentrum::Pages::PropertyParser.new(@agent, @logger)
  end
end

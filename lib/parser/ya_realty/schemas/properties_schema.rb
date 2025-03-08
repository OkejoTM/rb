class Parser::YaRealty::Schemas::PropertiesSchema < Parser::BaseSchema
  include Parser::FileTypeSchema

  step :load_xml_file
  map :parse_urls
  map :deactivate_not_founded_properties
  tee :log_separated_properties
  step :parse_properties
  map :remove_xml_file

  def url_grabber
    Parser::YaRealty::Pages::UrlGrabber.new(@agent, @logger)
  end

  def property_parser
    Parser::YaRealty::Pages::PropertyParser.new(@agent, @logger)
  end
end

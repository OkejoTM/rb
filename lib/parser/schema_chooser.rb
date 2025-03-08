class Parser::SchemaChooser
  SCHEMA_MAP = {
    'imperof.com' => Parser::Imperof::Schemas::AgencySchema,
    'prian.ru' => Parser::Prian::Schemas::AgenciesSchema,
    'tools.grekodom.com' => Parser::Grekodom::Schemas::PropertiesSchema,
    'israelhome.ru' => Parser::Israelhome::Schemas::AgencySchema,
    'www.czech-estate.cz' => Parser::DevCentrum::Schemas::PropertiesSchema,
    'xml.afy.ru' => Parser::SmartRich::Schemas::PropertiesSchema,
    'www.elgrekorealestate.com' => Parser::YaRealty::Schemas::PropertiesSchema,
    'media.egorealestate.com' => Parser::PortugalEstate::Schemas::PropertiesSchema,
  }.freeze

  class << self
    def get_schema_by_url(url)
      SCHEMA_MAP.fetch(get_domain(url))
    end

    # @param [String] domain
    # @return Parser::Schemas::BaseSchema
    def get_schema_by_domain(domain)
      SCHEMA_MAP.fetch(domain)
    end

    def separate_by_domain(links)
      links.group_by { |link| get_domain(link) }
    end

    def get_domain(url)
      uri = URI.parse(url)
      uri.hostname
    end
  end
end

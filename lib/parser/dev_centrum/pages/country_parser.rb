class Parser::DevCentrum::Pages::CountryParser
  COUNTRIES_URL = 'http://prian.ru/files/xml/countries.xml'

  def call(id)

    file = open(COUNTRIES_URL)

    begin
      reader = Nokogiri::XML::Reader(file)

      reader.each do |node|
        next unless country?(node)

        xml_node = Nokogiri.parse(node.outer_xml)
        next unless check_country_id(xml_node, id)

        return get_country_name(xml_node)
      end


    ensure
      File.delete(file) if File.exist?(file)
    end

  end

  private
    def country?(node)
      node.name == 'country' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
    end

    def check_country_id(node, id)
      node.at('country_id').text == id
    end

    def get_country_name(node)
      node.at('name_rus').text
    end
end

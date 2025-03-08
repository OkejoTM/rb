class Parser::DevCentrum::Pages::DistrictParser
  DISTRICTS_URL = 'http://prian.ru/files/xml/districts.xml'

  def call(id)

    file = open(DISTRICTS_URL)

    begin
      reader = Nokogiri::XML::Reader(file)

      reader.each do |node|
        next unless district?(node)

        xml_node = Nokogiri.parse(node.outer_xml)
        next unless check_district_id(xml_node, id)

        return get_district_name(node)
      end


    ensure
      File.delete(file) if File.exist?(file)
    end

  end

  private
    def district?(node)
      node.name == 'district' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
    end

    def check_district_id(node, id)
      node.at('district_id').text == id
    end

    def get_district_name(node)
      node.at('name_rus').text
    end
end

module Parser::FileTypeParser

  # Итерирует по файлу с помощью Nokogiri::XML::Reader
  # Пропускает ноды которые не являются стартовыми и не совпадают по условию +property_node?+
  # @param [File] file
  def xml_iterator(file)
    reader = Nokogiri::XML::Reader(file)

    reader.each do |node|
      next unless property_node?(node) && start_node?(node)
      property_node = Nokogiri.parse(node.outer_xml)
      yield(property_node)
    end
  end

  protected

    def property_node?(node)
      raise NotImplementedError
    end

  private

    def start_node?(node)
      node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
    end
end

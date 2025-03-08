class Parser::PortugalEstate::Pages::PropertyParser < Parser::Pages::FileType::BasePropertyPage

  def parsed_property(parsed_node)
    new_property = parse_attributes(parsed_node, :ru, parser_class)
    new_property.merge!(parse_attributes(parsed_node, :en, parser_class))
  end

  def identifier_field(parsed_property)
    parsed_property[:external_link]
  end

  protected

    def parser_class
      Parser::PortugalEstate::Attributes::PropertyAttributes
    end

    def attribute_parser_map
      {
        ru: {
          external_link: :external_link,
          building_year: :building_year,
          room_count: :room_count,
          is_active: :is_active,
          moderated: :moderated,
          parsed: :parsed,

          for_sale: :for_sale,
          sale_price: :price,
          sale_price_unit: :price_unit,
          price_on_request: :price_on_request?,

          area: :area,
          area_unit: :default_unit,
          plot_area: :plot_area,
          plot_area_unit: :default_unit,
          description_ru: :description_ru,
          pictures: :imgs,
          agency_link: :agency_link,

          level: :level,
          level_count: :level_count,
          bathroom_count: :bathroom_count,
          bedroom_count: :bedroom_count
        },
        en: {
          property_type_en: :property_type,
          country_name_en: :country,
          rest_address_en: :rest_address,
          region_ru: :region,
          city_ru: :city,
        }
      }
    end

    def property_node?(node)
      node.name == 'Row'
    end
end

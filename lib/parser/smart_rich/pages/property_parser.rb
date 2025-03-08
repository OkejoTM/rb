class Parser::SmartRich::Pages::PropertyParser < Parser::Pages::FileType::BasePropertyPage

  def parsed_property(parsed_node)
    parse_attributes(parsed_node, :ru, parser_class)
  end

  def identifier_field(parsed_property)
    parsed_property[:external_link]
  end

  protected

    def property_node?(node)
      node.name == 'object'
    end

    def parser_class
      Parser::SmartRich::Attributes::PropertyAttributes
    end

    def attribute_parser_map
      {
        ru: {
          external_link: :external_link,
          property_type_ru: :property_type,
          building_year: :building_year,
          room_count: :room_count,
          is_active: :is_active,
          moderated: :moderated,
          parsed: :parsed,

          for_sale: :for_sale,
          sale_price: :price,
          sale_price_unit: :price_unit,
          price_on_request: :price_on_request?,

          rent_price_per_day: :rent_price_per_day,
          rent_price_unit_per_day: :price_unit,
          rent_price_per_month: :rent_price_per_month,
          rent_price_unit_per_month: :price_unit,
          rent_price_per_year: :rent_price_per_year,
          rent_price_unit_per_year: :price_unit,

          country_name_ru: :country,
          rest_address_ru: :rest_address,
          region_ru: :region,
          city_ru: :city,
          latitude: :latitude,
          longitude: :longitude,

          area: :area,
          area_unit: :square_unit,
          plot_area: :plot_area,
          plot_area_unit: :square_unit,
          description_ru: :description_ru,
          h1_ru: :h1_ru,
          pictures: :imgs,
          agency_link: :agency_link,

          level: :level,
          level_count: :level_count,
          bathroom_count: :bathroom_count,
          bedroom_count: :bedroom_count
        }
      }
    end
end

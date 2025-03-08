class Parser::Grekodom::Pages::PropertyParser < Parser::YaRealty::Pages::PropertyParser

  protected

    def parser_class
      Parser::Grekodom::Attributes::PropertyAttributes
    end

    def attribute_parser_map
      {
        ru: {
          external_link: :external_link,
          offer: :offer,
          property_type_ru: :property_type,
          building_year: :building_year,
          room_count: :room_count,
          is_active: :is_active,
          moderated: :moderated,
          parsed: :parsed,

          for_sale: :for_sale,
          sale_price: :sale_price,
          sale_price_unit: :price_unit,
          price_on_request: :price_on_request?,

          rent_price_per_day: :rent_price_per_day,
          rent_price_unit_per_day: :price_unit,
          rent_price_per_month: :rent_price_per_month,
          rent_price_unit_per_month: :price_unit,

          to_airport: :to_airport,
          to_airport_unit: :default_distance_unit,
          to_historical_city_center: :to_historical_city_center,
          to_historical_city_center_unit: :default_distance_unit,
          to_sea: :to_sea,
          to_sea_unit: :default_distance_unit,

          country_name_ru: :country,
          rest_address_ru: :rest_address,
          region_ru: :region,
          city_ru: :city,
          latitude: :latitude,
          longitude: :longitude,

          area: :area,
          area_unit: :area_unit,
          plot_area: :plot_area,
          plot_area_unit: :plot_area_unit,
          description_ru: :description_ru,
          pictures: :imgs,
          agency_link: :agency_link,

          level: :level,
          level_count: :level_count,
          bathroom_count: :bathroom_count,
          bedroom_count: :bedroom_count
        },
        en: {
          description_en: :description_en,
        }
      }
    end
end

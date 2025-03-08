class Parser::DevCentrum::Pages::PropertyParser < Parser::Pages::FileType::BasePropertyPage

  def initialize(agent, logger)
    @last_property = {}

    super(agent, logger)
  end

  def identifier_field(parsed_property)
    parsed_property[:external_link]
  end

  def parsed_property(parsed_node)
    language = parser_class.new(parsed_node).language

    current_property = parse_attributes(parsed_node, language.to_sym, parser_class)
    merge_attributes(current_property)
  end

  def merge_attributes(current_property)
    # Проверяем является ли текущий объект недвижимости тем же, что и этот
    # Используется для описания объекта на разных языках
    @last_property =
      if current_property[:id] == @last_property[:id]
        current_property.merge!(@last_property)
        {}
      else
        current_property
      end

    current_property
  end

  protected

    def parser_class
      Parser::DevCentrum::Attributes::PropertyAttributes
    end

    def attribute_parser_map
      {
        en: {
          description_en: :description,
          h1_en: :h1,
        },
        ru: {
          moderated: :moderated,
          parsed: :parsed,
          is_active: :is_active,
          external_link: :unique_id,
          agency_link: :agency_link,

          description_ru: :description,
          h1_ru: :h1,
          property_type_ru: :type,

          for_sale: :for_sale,
          price_on_request: :price_on_request?,
          sale_price_unit: :price_unit,
          sale_price: :price,
          rent_price_per_day: :rent_price_per_day,
          rent_price_unit_per_day: :price_unit,
          rent_price_per_week: :rent_price_per_week,
          rent_price_unit_per_week: :price_unit,
          rent_price_per_month: :rent_price_per_month,
          rent_price_unit_per_month: :price_unit,

          to_airport: :to_airport,
          to_airport_unit: :to_airport_unit,
          to_railroad_station: :to_railroad_station,
          to_railroad_station_unit: :to_railroad_station_unit,
          to_beach: :to_beach,
          to_beach_unit: :to_beach_unit,
          to_historical_city_center: :to_historical_city_center,
          to_historical_city_center_unit: :to_historical_city_center_unit,
          to_nearest_big_city: :to_nearest_big_city,
          to_nearest_big_city_unit: :to_nearest_big_city_unit,
          to_food_stores: :to_food_stores,
          to_food_stores_unit: :to_food_stores_unit,
          to_medical_facilities: :to_medical_facilities,
          to_medical_facilities_unit: :to_medical_facilities_unit,
          to_metro_station: :to_metro_station,
          to_metro_station_unit: :to_metro_station_unit,
          to_state_border: :to_state_border,
          to_state_border_unit: :to_state_border_unit,

          country_name_ru: :country,
          latitude: :latitude,
          longitude: :longitude,

          building_year: :building_year,
          room_count: :room_count,
          area: :area,
          area_unit: :area_unit,
          plot_area: :plot_area,
          plot_area_unit: :plot_area_unit,
          studio: :studio,
          construction_phase: :construction_phase,
          level: :level,
          level_count: :level_count,
          bathroom_count: :bathroom_count,
          bedroom_count: :bedroom_count,

          pictures: :imgs,
        }
      }
    end

    def property_node?(node)
      node.name == 'object'
    end
end

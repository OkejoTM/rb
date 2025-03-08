class Parser::Prian::Pages::PropertyPage < Parser::Pages::WebType::BasePropertyPage
  include Parser::Prian::Pages::ParserUtils

  def parse_page(page)
    new_property = parse_attributes(page, :ru, parser_class)

    locales.each do |locale|
      next if locale == :ru
      page_foreign = load_locale(page, @agent, locale)
      new_property.merge!(parse_attributes(page_foreign, locale, parser_class))
    end

    new_property
  end

  def load_property_page(property_url)
    @agent.reset # resets language
    @agent.load_page(property_url)
  end

  def locales
    @locales ||= attribute_parser_map.keys
  end

  def parser_class
    Parser::Prian::Attributes::PropertyAttributes
  end

  def attribute_parser_map
    {
      en: {
        h1_en: :h1,
        attributes_en: :attributes,
        country_name_en: :country,
        rest_address_en: :rest_address,
        property_type_en: :type,
        additional_area_en: :additional_area,
        description_en: :description
      },
      ru: {
        h1_ru: :h1,
        attributes_ru: :attributes,
        moderated: :moderated,
        parsed: :parsed,
        latitude: :latitude,
        longitude: :longitude,
        property_type_ru: :type,
        sale_price_unit: :sale_price_unit,
        rent_price_per_day: :rent_price_per_day,
        rent_price_unit_per_day: :sale_price_unit,
        rent_price_per_week: :rent_price_per_week,
        rent_price_unit_per_week: :sale_price_unit,
        rent_price_per_month: :rent_price_per_month,
        rent_price_unit_per_month: :sale_price_unit,
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
        to_ski_lift: :to_ski_lift,
        to_ski_lift_unit: :to_ski_lift_unit,
        to_sea: :to_beach,
        to_sea_unit: :to_beach_unit,
        to_metro_station: :to_metro_station,
        to_metro_station_unit: :to_metro_station_unit,
        to_state_border: :to_state_border,
        to_state_border_unit: :to_state_border_unit,
        country_name_ru: :country,
        rest_address_ru: :rest_address,
        additional_area_ru: :additional_area,
        external_link: :external_link,
        for_sale: :for_sale,
        sale_price: :price,
        building_year: :building_year,
        last_repair: :last_repair,
        room_count: :room_count,
        price_on_request: :price_on_request,
        area: :area,
        area_unit: :area_unit,
        plot_area: :plot_area,
        plot_area_unit: :plot_area_unit,
        is_active: :is_active,
        description_ru: :description,
        studio: :studio,
        construction_phase: :construction_phase,
        pictures: :imgs,
        agency_link: :agency_link,

        # rentable_area: '',
        # rentable_area_unit: '',
        rental_yield_per_year: :rental_yield_per_year,
        rental_yield_per_year_unit: :rental_yield_per_year_unit,
        # rental_yield_per_month: '',
        # rental_yield_per_month_unit: '',
        # min_absolute_income: '',
        # min_absolute_income_unit: '',
        # min_amount_of_own_capital: '',

        level: :level,
        level_count: :level_count,
        bathroom_count: :bathroom_count,
        bedroom_count: :bedroom_count
      }
    }
  end
end

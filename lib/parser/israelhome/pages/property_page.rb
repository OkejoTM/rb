class Parser::Israelhome::Pages::PropertyPage < Parser::Pages::WebType::BasePropertyPage
  include Parser::Israelhome::Pages::ParserUtils

  define_message :other_country_type,
                 "Невозможно получить местоположение: %s\n"

  def parse_page(page)
    new_property = parse_attributes(page, :ru, parser_class)

    if new_property[:type_group] == :other_country
      @logger.warn(other_country_type(URI.decode(page.uri.to_s)))
      return
    end

    page_en = load_locale(@agent, :eng, page.uri.to_s)

    if page_en.blank?
      return new_property
    end

    eng_property = parse_attributes(page_en, :en, parser_class)
    new_property.merge!(eng_property)
  end

  def load_property_page(property_url)
    load_locale(@agent, :rus, property_url) # rus/eng локали урл у сайта
  end

  def parser_class
    Parser::Israelhome::Attributes::PropertyAttributes
  end

  def attribute_parser_map
    {
      ru: {
        h1_ru: :h1,
        description_ru: :description,
        agency_link: :agency_link,
        pictures: :imgs,
        is_active: :is_active,
        moderated: :moderated,
        parsed: :parsed,

        attributes_ru: :attributes,
        type_group: :type_group,

        latitude: :latitude,
        longitude: :longitude,

        property_type_ru: :type,
        property_tags: :property_tags,

        country_name_ru: :country_ru,
        rest_address_ru: :rest_address,

        external_link: :external_link,

        for_sale: :for_sale,
        sale_price: :sale_price,
        sale_price_unit: :sale_price_unit,
        price_on_request: :price_on_request,
        rent_price_per_day: :rent_price_per_day,

        area: :area,
        area_unit: :area_unit,
        plot_area: :plot_area,
        plot_area_unit: :plot_area_unit,

        room_count: :room_count,
        bedroom_count: :bedroom_count,
      },
      en: {
        h1_en: :h1,
        description_en: :description,

        property_type_en: :type,

        attributes_en: :attributes,

        country_name_en: :country_en,
        rest_address_en: :rest_address,
      }
    }
  end
end

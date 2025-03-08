class Parser::Imperof::Pages::PropertyPage < Parser::Pages::WebType::BasePropertyPage
  include Parser::Imperof::Pages::ParserUtils

  define_message :only_english,
                 "Пропущена %s т.к. загрузилась английская версия"

  def parse_page(page)
    if en?(page) # по запросу русской страницы, загрузилась английская
      @logger.warn(only_english(URI.decode(page.uri.to_s)))
      return
    end

    new_property = parse_attributes(page, :ru, parser_class)

    page_en = load_locale(@agent, :en, page.uri.to_s)

    if page_en.blank? || ru?(page_en) # Некоторые недвижимости не имеют переведенных вариантов
      return new_property
    end

    eng_property = parse_attributes(page_en, :en, parser_class)
    new_property.merge!(eng_property)
  end

  def load_property_page(property_url)
    load_locale(@agent, :ru, property_url)
  end

  def parser_class
    Parser::Imperof::Attributes::PropertyAttributes
  end

  def attribute_parser_map
    {
      en: {
        h1_en: :h1,
        attributes_en: :attributes,
        country_name_en: :country_en,
        rest_address_en: :rest_address,
        property_type_en: :type,
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
        country_name_ru: :country_ru,
        rest_address_ru: :rest_address,
        external_link: :external_link,
        for_sale: :for_sale,
        sale_price: :price,
        building_year: :building_year,
        price_on_request: :price_on_request,
        area: :area,
        area_unit: :area_unit,
        is_active: :is_active,
        description_ru: :description,
        studio: :studio,
        pictures: :imgs,
        agency_link: :agency_link,
        bathroom_count: :bathroom_count,
        bedroom_count: :bedroom_count,
      }
    }
  end
end

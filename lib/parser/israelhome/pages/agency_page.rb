class Parser::Israelhome::Pages::AgencyPage < Parser::Pages::WebType::BaseAgencyPage
  include Parser::Israelhome::Pages::ParserUtils

  def load_agency_page(agency_url)
    load_about(@agent, :rus)
  end

  def parse_page(page)
    agency_attrs = parse_attributes(page, %i[ru about_page], parser_class)

    page_en = load_about(@agent, :eng)
    agency_attrs.merge!(parse_attributes(page_en, %i[en about_page], parser_class))

    page = load_contacts(@agent, :rus)
    agency_attrs.merge!(parse_attributes(page, %i[ru contact_page], parser_class))

    page_en = load_contacts(@agent, :eng)
    agency_attrs.merge!(parse_attributes(page_en, %i[en contact_page], parser_class))
  end

  def parser_class
    Parser::Israelhome::Attributes::AgencyAttributes
  end

  def attribute_parser_map
    {
      ru: {
        about_page: {
          about_ru: :about,
          name_ru: :name,
          website: :website,
          org_name_ru: :name,
          logo: :logo,
          is_active: :is_active,
        },
        contact_page: {
          contacts_ru: :contacts_ru,
        },
      },
      en: {
        about_page: {
          name_en: :name,
          org_name_en: :name,
          about_en: :about,
        },
        contact_page: {
          contacts_en: :contacts_en,
        },
      }
    }
  end
end

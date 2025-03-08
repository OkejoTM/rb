class Parser::Imperof::Pages::AgencyPage < Parser::Pages::WebType::BaseAgencyPage
  include Parser::Imperof::Pages::ParserUtils

  def load_agency_page(agency_url)
    @agent.reset # resets language
    load_about(@agent, :ru) # прогреваем сайт imperof. По какой-то неизвестной причине первое открытие сайта всегда откроет en версию, даже для ru локали

    load_about(@agent, :ru)
  end

  def parse_page(page)
    agency_attrs = parse_attributes(page, %i[ru about_page], parser_class)

    page_en = load_about(@agent, :en)
    agency_attrs.merge!(parse_attributes(page_en, %i[en about_page], parser_class))

    page = load_contacts(@agent, :ru)
    agency_attrs.merge!(parse_attributes(page, %i[ru contact_page], parser_class))
  end

  def parser_class
    Parser::Imperof::Attributes::AgencyAttributes
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
          is_active: :is_active
        },
        contact_page: {
          other_contacts_ru: :other_contacts_ru,
          contacts_ru: :contacts_ru
        },
      },
      en: {
        about_page: {
          name_en: :name,
          about_en: :about
        }
      }
    }
  end
end

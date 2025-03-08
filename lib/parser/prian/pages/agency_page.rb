class Parser::Prian::Pages::AgencyPage < Parser::Pages::WebType::BaseAgencyPage
  include Parser::Prian::Pages::ParserUtils

  def call(agency_urls, agency_handler: nil)
    property_urls = []
    locales = attribute_parser_map.keys

    agency_urls.each do |agency_url|
      @agent.reset # resets language
      page = @agent.load_page(agency_url)

      if page.blank?
        if agency_handler.present? && !agency_handler.new?
          process_parsed(agency_handler, { is_active: false }, url: agency_url)
        end
        @logger.warn(empty_response(URI.decode(agency_url)))
        next
      end

      new_agency = parse_attributes(page, :ru, parser_class)

      locales.each do |locale|
        next if locale == :ru
        page_foreign = load_locale(page, @agent, locale)
        new_agency.merge!(parse_attributes(page_foreign, locale, parser_class))
      end

      active_properties = parse_properties_pages(page, agency_url)

      # обновляем недвижимости только для активных агентств
      if new_agency[:is_active]
        property_urls.concat(active_properties)
        new_agency[:prian_properties_links] = active_properties
        new_agency[:is_active] = true # оставляем агентство активным
      end

      next if agency_handler.blank?

      process_parsed(agency_handler, new_agency, url: agency_url)

    rescue => e
      @logger.error(error_property_parse(agency_url, e.message, e.backtrace.join("\n")))
    end

    property_urls.uniq
  end

  def parser_class
    Parser::Prian::Attributes::AgencyAttributes
  end

  def parse_properties_url(page)
    page.css('a.company-block').map { |item| wrap_url(item['href']) }
  end

  def parse_properties_pages(page, agency_url)
    property_urls = []

    loop do
      new_property_urls = parse_properties_url(page)
      property_urls.concat(new_property_urls)

      page_num = calculate_next_step(page)

      break if page_num.blank?

      next_page = load_next_page(agency_url, page_num)

      if next_page.blank?
        @logger.warn("Страница #{page_num} вернулась пустой")
        break
      end

      page = next_page
    end

    property_urls
  end

  def load_next_page(agency_url, page_num)
    @agent.load_page(next_page_url(agency_url, page_num))
  end

  def next_page_url(agency_url, page_number)
    without_html = agency_url.gsub('.html', '')
    page_url(page_number, "#{without_html}/search/")
  end

  def page_url(page_number, url)
    step_url_param = '?next='
    suffix =
        if page_number.zero?
          ''
        else
          "#{step_url_param}#{page_number}"
        end

    "#{url}#{suffix}"
  end

  def attribute_parser_map
    {
      ru: {
        name_ru: :name,
        about_ru: :about,
        website: :website,
        prian_link: :prian_link,
        org_name_ru: :name,
        logo: :logo,
        contact_people_ru: :contact_people,
        other_contacts_ru: :other_contacts,
        messengers: :messengers,
        is_active: :is_active
      },
      en: {
        name_en: :name,
        about_en: :about,
        org_name_en: :name,
        contact_people_en: :contact_people,
        other_contacts_en: :other_contacts,
      }
    }
  end
end

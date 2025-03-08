class Parser::Prian::Pages::SearchPage < Parser::BasePage
  include Parser::ParserUtils

  def call(url)
    page_num = 0
    agency_urls = []

    loop do
      page = @agent.load_page(page_url(page_num, url))

      new_agency_urls = parse_agency_urls(page)
      agency_urls.concat(new_agency_urls)

      page_num = calculate_next_step(page)

      break if page_num.blank?
    end

    agency_urls
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

  def parse_agency_urls(page)
    page.css('a.company-item__name').map { |item| wrap_url(item['href']) }
  end
end

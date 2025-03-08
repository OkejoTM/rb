class Parser::Imperof::Pages::SearchPage < Parser::BasePage
  include Parser::Imperof::Pages::ParserUtils
  include Parser::ParserUtils

  # Warning: ссылки на недвижимости в английской локали
  def call
    property_urls = []
    page_num = 1

    loop do
      url = page_url(page_num, :ru)
      @logger.info("Парсим страницу #{url} на предмет недвижимостей")

      page = @agent.load_page(url)

      page_num = next_page_num(page)

      break if page_num.blank?

      new_property_urls = parse_property_urls(page)
      property_urls.concat(new_property_urls)
    rescue => e
      @logger.error("Ошибка при парсинге #{page_num} страницы недвижимости.\n #{e.message}\n#{e.backtrace.join("\n")}")
    end

    property_urls
  end

  def parse_property_urls(page)
    page.css('.more-details').map { |a| a['href'] }
  end

  def page_url(page_num, locale)
    {
      ru: "https://imperof.com/ru/property-search-2/page/#{page_num}/",
      en: "https://imperof.com/en/property-search/page/#{page_num}/"
    }[locale]
  end

  def next_page_num(page)
    btn = page.css('a.real-btn').find { |btn| 'Next'.in?(btn.text) }
    return if btn.blank?
    last_page_href = btn['href']
    last_page_href.match(/(?<=\/page\/)\d+(?!:\/)/).to_s.to_i
  end
end

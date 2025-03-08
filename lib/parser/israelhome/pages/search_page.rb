class Parser::Israelhome::Pages::SearchPage < Parser::BasePage
  include Parser::Israelhome::Pages::ParserUtils
  include Parser::ParserUtils

  def call
    property_urls = []

    %i[sell rent].each do |type|
      new_properties = parse_urls(type)
      property_urls.concat(new_properties)
    end

    property_urls
  end

  def parse_property_urls(page)
    page.css('.cat_item_title > a').map { |a| "http://israelhome.ru#{a['href']}" }
  end

  def page_url(page_num, type)
    {
      sell: "http://israelhome.ru/rus/offers_in_israel/?num=#{page_num}/",
      rent: "http://arenda.israelhome.ru/rus/apartment_rent_in_israel/?num=#{page_num}/",
    }[type]
  end

  def parse_urls(type)
    property_urls = []
    page_num = 1

    loop do
      url = page_url(page_num, type)
      @logger.info("Парсим страницу #{url} на предмет недвижимостей")

      page = @agent.load_page(url)

      page_num += 1

      new_property_urls = parse_property_urls(page)

      break if new_property_urls.blank?

      property_urls.concat(new_property_urls)
    rescue => e
      @logger.error("Ошибка при парсинге #{page_num} страницы недвижимости.\n #{e.message}\n#{e.backtrace.join("\n")}")
    end

    property_urls
  end
end

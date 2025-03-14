class Parsers::Vartur::Pages::SearchPage < Parser::BasePage
  include ActiveModel::Validations
  include Parser::ParserUtils

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call
    property_urls = []
    page_num = 1

    loop do
      url = page_url(page_num)
      @logger.info("Парсинг страницы #{url} на предмет недвижимости")

      page = @agent.load_page(url)

      page_num += 1

      new_property_urls = parse_property_urls(page)

      break if new_property_urls.blank?

      property_urls.concat(new_property_urls)
      break
    rescue => e
      @logger.error("Ошибка при парсинге #{page_num} страницы недвижимости.\n #{e.message}\n#{e.backtrace.join("\n")}")
    end

    property_urls
  end

  private

    def parse_property_urls(page)
      links = page.css('td.whitespace-nowrap.px-2.py-4.w-48.min-w-40 a').map { |a| a['href'] }.uniq

      links.map do |url|
        property_id = url.match(/\d+$/).to_s
        {
          en: "https://www.vartur.com/listings/#{property_id}",
          ru: "https://www.vartur.com/ru/spiski/#{property_id}"
        }
      end
    end

    def page_url(page_num)
      "https://vartur.com/property/for-sale/turkey?page=#{page_num}"
    end
end

class Parsers::Vartur::Pages::SearchPage < Parsers::BasePage
  include ActiveModel::Validations
  include Parsers::ParserUtils

  attr_reader :agent, :logger, :result

  validates :agent, presence: true
  validates :logger, presence: true

  LOCATIONS = %w[turkey dubai].freeze

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
    @result = []
  end

  def call
    return false unless valid?

    LOCATIONS.each do |location|
      page_num = 1

      loop do
        url = page_url(location, page_num)
        @logger.info("Парсинг страницы #{url} на предмет недвижимости")

        page = @agent.load_page(url)

        page_num += 1

        new_property_urls = parse_property_urls(page)

        break if new_property_urls.blank?

        new_property_urls = new_property_urls
        @result.concat(new_property_urls)
      rescue => e
        @logger.error("Ошибка при парсинге #{page_num} страницы недвижимости.\n #{e.message}\n#{e.backtrace.join("\n")}")
        return false
      end
    end
    true
  end

  private

    def parse_property_urls(page)
      page.css('td.whitespace-nowrap.px-2.py-4.w-48.min-w-40 a')
          .map { |a| a['href'] }
          .uniq
          .map { |url| "#{wrap_url(Parsers::Vartur::Schema::AGENCY_URL)}/listings/#{url.match(/\d+$/).to_s}" }
    end

    def page_url(location, page_num)
      "#{wrap_url(Parsers::Vartur::Schema::AGENCY_URL)}/property/for-sale/#{location}?page=#{page_num}"
    end
end

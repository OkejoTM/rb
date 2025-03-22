class Parsers::Vartur::Pages::AgencyPage < Parsers::BasePage
  include ActiveModel::Validations

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  LOCALES = %i[en ru].freeze

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call(agency_url)
    return false unless valid?
    @logger.info("Старт парсинга агенства\n")

    agency_attrs = parse_pages
    return if agency_attrs.blank?

    handler = Parsers::Vartur::Operations::Agency::Upsert.new
    process_parsed(handler, agency_attrs, identifier: agency_url)
  rescue => e
    @logger.error("Ошибка при парсинге. #{agency_url}\n#{e.message}\n#{e.backtrace.first}\n")
    false
  end

  private

    def attribute_parser_map
      {
        en: {
          about_page: {
            name_en: :name,
            about_en: :about_en,
            logo: :logo,
            website: :website,
            is_active: :is_active
          },
          contact_page: {
            other_contacts_en: :other_contacts_en,
            contacts_en: :contacts_en
          }
        },
        ru: {
          about_page: {
            name_ru: :name,
            about_ru: :about_ru
          }
        }
      }
    end

    def parse_pages
      agency_attrs = {}

      LOCALES.each do |locale|
        @agent.reset

        about_page = @agent.load_page(about_url(locale))
        if about_page.present?
          about_attrs = parse_attributes(about_page, [locale, :about_page], Parsers::Vartur::Attributes::AgencyAttributes)
          agency_attrs.merge!(about_attrs)
        end
      end
      contact_page = load_contacts(@agent)
      agency_attrs.merge!(parse_attributes(contact_page, %i[en contact_page], Parsers::Vartur::Attributes::AgencyAttributes))

      agency_attrs
    end

    def about_url(locale)
      {
        en: 'https://www.vartur.com/about-us',
        ru: 'https://www.vartur.com/ru/o-nas'
      }[locale]
    end

    def load_contacts(agent)
      agent.load_page('https://www.vartur.com/contact-us')
    end
end

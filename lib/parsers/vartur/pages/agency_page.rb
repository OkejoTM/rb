class Parsers::Vartur::Pages::AgencyPage < Parsers::BasePage
  include ActiveModel::Validations

  attr_reader :agent, :logger

  validates :agent, presence: true
  validates :logger, presence: true

  LOCALES = Parsers::Vartur::Schema::LOCALES

  def initialize(agent, logger)
    @agent = agent
    @logger = logger
  end

  def call(agency_url)
    return false unless valid?
    @logger.info("Старт парсинга агенства\n")

    agency_attrs = parse_pages
    return if agency_attrs.blank?

    process_parsed(agency_url, agency_attrs)
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

    def process_parsed(agency_url, attrs)
      handler = Parsers::Vartur::Operations::Agency::Upsert.new
      success = handler.call(agency_url, attrs)

      if !success
        @logger.error(handler.errors.full_messages)
      else
        entity = handler.result
        new_or_updated = entity.previously_new_record? ? 'добавлена' : 'изменена'
        @logger.info("Сущность #{entity.id} была #{new_or_updated}")
        @logger.info("Переданные параметры: #{attrs}")
      end
      success
    end

    def about_url(locale)
      @about_url ||= {
        en: "#{Parsers::ParserUtils.wrap_url(Parsers::Vartur::Schema::AGENCY_URL)}/about-us",
        ru: "#{Parsers::ParserUtils.wrap_url(Parsers::Vartur::Schema::AGENCY_URL)}/ru/o-nas"
      }

      @about_url[locale]
    end

    def load_contacts(agent)
      agent.load_page("#{Parsers::ParserUtils.wrap_url(Parsers::Vartur::Schema::AGENCY_URL)}/contact-us")
    end
end

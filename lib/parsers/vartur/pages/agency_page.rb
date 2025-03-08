class Parsers::Vartur::Pages::AgencyPage
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

    def process_parsed(agency_url, attrs)
      handler = Parsers::Vartur::Operations::Agency::Upsert.new
      result = handler.call(agency_url, attrs)

      if handler.errors.present?
        @logger.error(handler.errors.full_messages)
      else
        entity = handler.entity
        new_or_updated = entity.new_record? ? 'добавлена' : 'изменена'
        @logger.info("Сущность #{entity.id} была #{new_or_updated}")
        @logger.info("Переданные параметры: #{attrs}")
      end

      result
    end

    def parse_pages
      agency_attrs = {}

      LOCALES.each do |locale|
        @agent.reset

        about_page = load_about(@agent, locale)
        if about_page.present?
          about_attrs = parse_attributes(about_page, [locale, :about_page])
          agency_attrs.merge!(about_attrs)
        end

      end

      contact_page = load_contacts(@agent)
      agency_attrs.merge!(parse_attributes(contact_page, %i[en contact_page]))

      agency_attrs
    end

    def parse_attributes(page, map_path)
      parsed_hash = {}
      handler = Parsers::Vartur::Attributes::AgencyAttributes.new(page)
      method_list =
        if map_path.is_a? Array
          attribute_parser_map.dig(*map_path)
        else
          attribute_parser_map[map_path]
        end

      method_list.each do |attribute, method|
        parsed_hash[attribute] = handler.public_send(method)
      end
      parsed_hash
    end

    def load_about(agent, locale)
      case locale
        when :en
          agent.load_page('https://www.vartur.com/about-us')
        when :ru
          agent.load_page('https://www.vartur.com/ru/o-nas')
      end
    end

    def load_contacts(agent)
      agent.load_page('https://www.vartur.com/contact-us')
    end
end

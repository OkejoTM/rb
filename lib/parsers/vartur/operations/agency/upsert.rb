class Parsers::Vartur::Operations::Agency::Upsert
  include Parsers::Operation::Agency::Base
  include ActiveModel::Validations

  LOCALES = Parsers::Vartur::Schema::LOCALES

  attr_reader :result

  def call(agency_url, attributes)
    @result = find_agency(agency_url)

    if @result.new_record?
      add_seo(attributes)
      add_slug(attributes)
    end

    process_contacts(attributes)
    process_other_contacts(attributes)
    process_logo(attributes)

    save!(@result, attributes)
    true
  rescue => e
    errors.add(:base, message: e.message)
    false
  end

  private
    def find_agency(agency_url)
      result =
        ::Agency.includes(:logo,
                          :contacts,
                          :agency_other_contacts,
                          :contact_people,
                          :messengers,
                          messengers: [:messenger_type],
                          contact_people: [:contacts])
                .where(website: Parsers::ParserUtils.wrap_url(agency_url))
                .first

      result.presence || ::Agency.new
    end

    def process_other_contacts(attributes)
      parsed_attributes = attributes.slice(:other_contacts_ru, :other_contacts_en)
      agency_other_contacts = @result&.agency_other_contacts || []

      if agency_other_contacts.blank? && LOCALES.all? { |locale| parsed_attributes[:"other_contacts_#{locale}"].blank? }
        return
      end

      contacts_to_delete = mark_delete_other_contacts(agency_other_contacts, parsed_attributes)
      contacts_to_add_or_update = update_other_contacts(parsed_attributes)

      agency_other_contacts_attributes = contacts_to_delete + contacts_to_add_or_update

      if agency_other_contacts_attributes.present?
        attributes[:agency_other_contacts_attributes] = agency_other_contacts_attributes
      end
    end

    def mark_delete_other_contacts(agency_other_contacts, parsed_attributes)
      found_contacts_ids = parsed_attributes.values.reduce([]) do |memo, contacts_attrs|
        found = contacts_attrs.map { |contact_attr| find_agency_other_contacts_by_title(contact_attr[:title]) }.compact
        memo | found.map(&:id)
      end

      to_delete_contacts_ids = agency_other_contacts.map(&:id) - found_contacts_ids
      to_delete_contacts_ids.map { |contact_id| { id: contact_id, _destroy: true } }
    end

    def update_other_contacts(parsed_attributes)
      LOCALES.reduce([]) do |memo, locale|
        contacts_attrs = parsed_attributes[:"other_contacts_#{locale}"] || []

        contacts_attrs.each do |contact_attr|
          other_contact = find_agency_other_contacts_by_title(contact_attr[:title])

          other_contact_params =
            if other_contact.present?
              {
                id: other_contact.id,
                "title_#{locale}": contact_attr[:title],
                "content_#{locale}": contact_attr[:content]
              }
            else
              {
                "title_#{locale}": contact_attr[:title],
                "content_#{locale}": contact_attr[:content]
              }
            end

          memo.push(other_contact_params)
        end
        memo
      end
    end

    def process_contacts(attributes)
      parsed_attributes = attributes.slice(:contacts_ru, :contacts_en)
      contacts = @result&.contacts || []

      # Пропускаем, если нет контактов и атрибутов
      if contacts.blank? && LOCALES.all? { |locale| parsed_attributes[:"contacts_#{locale}"].blank? }
        return
      end

      contacts_to_delete = mark_delete_contacts(contacts, parsed_attributes)
      contacts_to_add_or_update = update_contacts(parsed_attributes)

      contacts_attributes = contacts_to_delete + contacts_to_add_or_update

      if contacts_attributes.present?
        attributes[:contacts_attributes] = contacts_attributes
      end
    end

    def mark_delete_contacts(contacts, parsed_attributes)
      found_contacts_ids = parsed_attributes.values.reduce([]) do |memo, contact_attrs|
        found_contacts = contact_attrs.map { |contact_attr| find_agency_contacts_by_value(contact_attr[:value]) }.compact
        memo | found_contacts.map(&:id)
      end

      to_delete_contacts_ids = contacts.map(&:id) - found_contacts_ids
      to_delete_contacts_ids.map { |contact_id| { id: contact_id, _destroy: true } }
    end

    def update_contacts(parsed_attributes)
      LOCALES.reduce([]) do |memo, locale|
        contacts_attrs = parsed_attributes[:"contacts_#{locale}"] || []

        contacts_attrs.each do |contact_attr|
          contact = find_agency_contacts_by_value(contact_attr[:value])
          next if contact.present?

          contact_type = find_contact_by_type(contact_attr[:contact_type])
          next if contact_type.blank?

          new_contact = {
            value: contact_attr[:value],
            contact_type_id: contact_type.id
          }

          memo.push(new_contact)
        end
        memo
      end
    end

    def process_logo(attributes)
      if attributes[:logo].present?
        logo = check_logo(attributes[:logo])
        if logo.present?
          attributes[:logo_attributes] = logo
        end
      end
    end

    def add_slug(attributes)
      attributes[:slug] = attributes[:name_en].parameterize
    end

    def add_seo(attributes)
      attributes[:seo_agency_page] = SeoAgencyPage.new_default_agency_page
    end

    def save!(result, attributes)
      permitted_attrs = permitted_params(attributes)
      result.assign_attributes(permitted_attrs)

      if result.save
        result
      else
        raise result&.errors&.messages&.to_json
      end
    end

    def find_agency_other_contacts_by_title(title)
      @result&.agency_other_contacts&.find do |contact|
        LOCALES.any? { |locale| contact.send(:"title_#{locale}") == title }
      end
    end

    def find_agency_contacts_by_value(value)
      @result&.contacts&.find { |contact| contact.value == value }
    end

    def find_contact_by_type(type)
      @contact_types ||= ContactType.all.to_a
      @contact_types.find do |contact|
        LOCALES.any? { |locale| contact.send(:"title_#{locale}") == type }
      end
    end
end

class Parsers::Vartur::Operations::Agency::Upsert
  include Parsers::Operation::Agency::Base
  include ActiveModel::Validations

  LOCALES = Parsers::Vartur::Schema::LOCALES

  attr_reader :entity

  def call(agency_url, attributes)
    @entity = find_agency(agency_url)

    if @entity.new_record?
      add_seo(attributes)
      add_slug(attributes)
    end

    process_contacts(attributes)
    process_other_contacts(attributes)
    process_logo(attributes)

    save(@entity, attributes)
  rescue => e
    errors.add(:base, message: e.message)
    false
  end

  private
    def find_agency(agency_url)
      entity =
        ::Agency.includes(:logo,
                          :contacts,
                          :agency_other_contacts,
                          :contact_people,
                          :messengers,
                          messengers: [:messenger_type],
                          contact_people: [:contacts])
                .where(website: Parsers::ParserUtils.wrap_url(agency_url))
                .first

      entity.presence || ::Agency.new
    end

    def process_other_contacts(attributes)
      parsed_attributes = attributes.slice(:other_contacts_ru, :other_contacts_en)
      agency_other_contacts = @entity&.agency_other_contacts || []
      agency_other_contacts_attributes = []

      if agency_other_contacts.blank? && LOCALES.all? { |locale| parsed_attributes[:"other_contacts_#{locale}"].blank? }
        return
      end

      mark_delete_other_contacts(agency_other_contacts, parsed_attributes, agency_other_contacts_attributes)

      add_other_contacts(parsed_attributes, agency_other_contacts_attributes)

      update_other_contacts(parsed_attributes, agency_other_contacts, agency_other_contacts_attributes)

      if agency_other_contacts_attributes.present?
        attributes[:agency_other_contacts_attributes] = agency_other_contacts_attributes
      end
    end

    def mark_delete_other_contacts(agency_other_contacts, parsed_attributes, agency_other_contacts_attributes)
      for_delete = []

      agency_other_contacts.each do |contact|
        found = false

        LOCALES.each do |locale|
          contacts_attrs = parsed_attributes[:"other_contacts_#{locale}"] || []

          contacts_attrs.each do |contact_attr|
            if contact_attr[:title] == contact.send(:"title_#{locale}")
              found = true
              break
            end
          end

          break if found
        end

        unless found
          for_delete.push(id: contact.id, _destroy: true)
        end
      end

      agency_other_contacts_attributes.concat(for_delete) if for_delete.present?
    end

    def add_other_contacts(parsed_attributes, agency_other_contacts_attributes)
      agency_contacts = @entity&.agency_other_contacts || []

      LOCALES.each do |locale|
        contacts_attrs = parsed_attributes[:"other_contacts_#{locale}"] || []

        contacts_attrs.each do |contact_attr|
          existing_contact = agency_contacts.find { |c| c.send(:"title_#{locale}") == contact_attr[:title] }

          # Если контакт уже существует, пропускаем его (он будет обработан в update_other_contacts)
          next if existing_contact.present?

          new_contact = {
            "title_#{locale}": contact_attr[:title],
            "content_#{locale}": contact_attr[:content]
          }

          agency_other_contacts_attributes.push(new_contact)
        end
      end
    end

    def update_other_contacts(parsed_attributes, agency_other_contacts, agency_other_contacts_attributes)
      LOCALES.each do |locale|
        contacts_attrs = parsed_attributes[:"other_contacts_#{locale}"] || []

        contacts_attrs.each do |contact_attr|
          other_contact = agency_other_contacts.find { |c| c.send(:"title_#{locale}") == contact_attr[:title] }

          if other_contact.present?
            updated_contact = {
              id: other_contact.id,
              "title_#{locale}": contact_attr[:title],
              "content_#{locale}": contact_attr[:content]
            }

            agency_other_contacts_attributes.push(updated_contact)
          end
        end
      end
    end

    def process_contacts(attributes)
      parsed_attributes = attributes.slice(:contacts_ru, :contacts_en)
      contacts = @entity&.contacts || []
      contacts_attributes = []

      # Пропускаем, если нет контактов и атрибутов
      if contacts.blank? && LOCALES.all? { |locale| parsed_attributes[:"contacts_#{locale}"].blank? }
        return
      end

      mark_delete_contacts(contacts, parsed_attributes, contacts_attributes)

      add_contacts(parsed_attributes, contacts, contacts_attributes)

      if contacts_attributes.present?
        attributes[:contacts_attributes] = contacts_attributes
      end
    end

    def mark_delete_contacts(contacts, parsed_attributes, contacts_attributes)
      for_delete = []

      contacts.each do |contact|
        found = false

        parsed_attributes.values.flatten.each do |contact_attr|
          if contact_attr[:value] == contact.value
            found = true
            break
          end
        end

        unless found
          for_delete.push(id: contact.id, _destroy: true)
        end
      end

      contacts_attributes.concat(for_delete) if for_delete.present?
    end

    def add_contacts(parsed_attributes, contacts, contacts_attributes)
      contact_types = ContactType.all.to_a

      LOCALES.each do |locale|
        contacts_attrs = parsed_attributes[:"contacts_#{locale}"] || []

        contacts_attrs.each do |contact_attr|
          contact = contacts.find { |c| c.value == contact_attr[:value] }
          next if contact.present?

          contact_type = contact_types.find { |ct| ct.send("title_#{locale}") == contact_attr[:contact_type] }
          next if contact_type.blank?

          new_contact = {
            value: contact_attr[:value],
            contact_type_id: contact_type.id
          }

          contacts_attributes.push(new_contact)
        end
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

    def save(entity, attributes)
      permitted_attrs = permitted_params(attributes)
      entity.assign_attributes(permitted_attrs)

      if entity.save
        entity
      else
        raise entity&.errors&.messages&.to_json
      end
    end
end

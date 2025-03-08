class Parser::Operation::ContactPerson::Base < Parser::Operation::BaseAttributesFor

  # Помечает контакты +contact_people+ не найденные в +contacts_attrs+ на удаление
  # @param [Array<ContactPerson>] contact_people
  # @param [Hash] contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def mark_for_delete_contact_people(contact_people, contacts_attrs, locales)
    mark_for_delete(contact_people, contacts_attrs.values.flatten) do |contact_person, contact_person_attr|
      variants = locales.map { |l| contact_person.send(:"name_#{l}") }

      contact_person_attr[:name].in?(variants)
    end
  end

  # Добавляет не существующие контакты людей
  # @param [Array<ContactPerson>] contact_people
  # @param [Hash] contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def add_new_contact_people(locales, contacts_attrs, contact_people: [])
    nested_attributes = []
    contact_types = contact_type_map

    locales.each do |locale|
      contacts_attrs[:"contact_people_#{locale}"].each do |contact_person_attrs|
        saved_contact_person = contact_people.find { |person| person.send(:"name_#{locale}") == contact_person_attrs[:name] }
        next if saved_contact_person.present?

        nested_attributes.push(new_contact_people_hash(locale, contact_person_attrs, contact_types))
      end
    end

    nested_attributes
  end

  def new_contact_people_hash(locale, contact_person_attrs, contact_types)
    contacts_of_person_attrs = contact_person_attrs[:contacts] # hash
    contacts_attributes = contacts_of_person_attrs.map { |type, value| { contact_type_id: contact_types[type]&.id, value: value } }

    {
      "name_#{locale}": contact_person_attrs[:name],
      "role_#{locale}": contact_person_attrs[:role],
      avatar_attributes: { remote_pic_url: contact_person_attrs[:img] },
      contacts_attributes: contacts_attributes
    }
  end

  def update_contact_people_hash(locale, saved_contact_person, contact_person_attrs, contact_types)
    contacts_of_person_attrs = contact_person_attrs[:contacts] # hash
    saved_contacts = saved_contact_person.contacts.to_a
    saved_contacts_nested_attrs = []

    # delete old contacts
    old_contacts = mark_for_delete(saved_contacts, contacts_of_person_attrs.values) do |saved_contact, value|
                     value == saved_contact.value
                   end

    saved_contacts_nested_attrs.concat(old_contacts)

    # add new
    existed_contacts = saved_contacts.map(&:value)
    new_contacts = contacts_of_person_attrs
                       .reject { |type, value| value.in?(existed_contacts) }
                       .map { |type, value| { contact_type_id: contact_types[type]&.id, value: value } }
    {
      id: saved_contact_person.id,
      "role_#{locale}": contact_person_attrs[:role],
      avatar_attributes: { remote_pic_url: contact_person_attrs[:img] },
      contacts_attributes: new_contacts + saved_contacts_nested_attrs
    }
  end

  # Обновляет существующие контакты людей
  # @param [Array<ContactPerson>] contact_people
  # @param [Hash] contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def update_contact_people(locales, contacts_attrs, contact_people)
    nested_attributes = []
    contact_types = contact_type_map

    locales.each do |locale|
      contacts_attrs[:"contact_people_#{locale}"].each do |contact_person_attrs|
        saved_contact_person = contact_people.find { |person| person.send(:"name_#{locale}") == contact_person_attrs[:name] }
        next if saved_contact_person.blank?

        nested_attributes.push(update_contact_people_hash(locale, saved_contact_person, contact_person_attrs, contact_types))
      end
    end

    nested_attributes
  end

  protected

    # Возвращает тип контакта в соответствии с label атрибутом
    # @return [ContactType]
    def contact_type_map
      contact_types = ContactType.all.to_a
      {
        mailto: contact_types.find { |c| 'E-mail' == c.title_en },
        tel: contact_types.find { |c| 'Phone' == c.title_en },
        skype: contact_types.find { |c| 'Skype' == c.title_en },
      }
    end
end

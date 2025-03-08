class Parser::Operation::Contact::Base < Parser::Operation::BaseAttributesFor

  # Помечает контакты +contacts+ не найденные в +contacts_attrs+ на удаление
  # @param [Array<Contact>] contacts
  # @param [Hash] contacts_attrs
  # @return [Array<Hash>]
  def mark_for_delete_contacts(contacts, contacts_attrs)
    mark_for_delete(contacts, contacts_attrs.values.flatten) do |contact, contact_attr|
      contact_attr[:value] == contact.value
    end
  end

  # Добавляет контакты +contacts_attrs+ не найденные в +contacts+ в массив на добавление
  # @param [Array<Symbol>] locales
  # @param [Hash] contacts_attrs
  # @param [Array<Contact>] contacts
  # @return [Array<Hash>]
  def add_not_existed_contacts(locales, contacts_attrs, contacts: [])
    contact_types = ContactType.all.to_a
    nested_attributes = []

    locales.each do |locale|
      c_a = contacts_attrs[:"contacts_#{locale}"]
      next if c_a.blank?

      c_a.each do |contact_attr|

        contact = contacts.find do |c|
          c.value == contact_attr[:value]
        end

        # единственное значимое поле у контакта - value. Если строка с таким значением уже есть, то обновлять ничего не нужно
        next if contact.present?

        params = contact_hash(locale, contact_types, contact_attr)

        next if params.blank?

        nested_attributes.push(params)
      end
    end

    nested_attributes
  end

  def contact_hash(locale, contact_types, contact_attr)
    contact_type = contact_types.find { |ct| ct.send("title_#{locale}") == contact_attr[:contact_type] }

    return if contact_type.blank? # Не самое лучшее решение. Но создавать типы еще сложнее

    {
      value: contact_attr[:value],
      contact_type_id: contact_type.id
    }
  end
end

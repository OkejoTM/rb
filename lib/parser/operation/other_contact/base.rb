class Parser::Operation::OtherContact::Base < Parser::Operation::BaseAttributesFor

  # Помечает контакты +other_contacts+ не найденные в +other_contacts_attrs+ на удаление
  # @param [Array<AgencyOtherContact>] other_contacts
  # @param [Hash] other_contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def mark_for_delete_other_contacts(locales, other_contacts, other_contacts_attrs)
    mark_for_delete(other_contacts, other_contacts_attrs.values.flatten) do |contact, contact_attr|
      variants = locales.map { |l| contact.send(:"title_#{l}") }

      contact_attr[:title].in?(variants)
    end
  end

  # добавляет контакты
  # @param [Hash] other_contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def add_other_contacts(locales, other_contacts_attrs)
    nested_attributes = []

    locales.each do |locale|
      c_a = other_contacts_attrs[:"other_contacts_#{locale}"]
      next if c_a.blank?

      c_a.each do |other_contact_attr|
        params = other_contacts_hash(locale, other_contact_attr)
        nested_attributes.push(params)
      end
    end

    nested_attributes
  end

  # Обновляет существующие модели AgencyOtherContact
  # Если похожий контакт не был найден, создает новый
  # @param [Array<AgencyOtherContact>] other_contacts
  # @param [Hash] other_contacts_attrs
  # @param [Array<Symbol>] locales
  # @return [Array<Hash>]
  def update_other_contacts(locales, other_contacts_attrs, other_contacts)
    nested_attributes = []

    locales.each do |locale|
      c_a = other_contacts_attrs[:"other_contacts_#{locale}"]
      next if c_a.blank?

      c_a.each do |other_contact_attr|
        other_contact = other_contacts.find do |c|
          c.send(:"title_#{locale}") == other_contact_attr[:title]
        end

        params = other_contacts_hash(locale, other_contact_attr, other_contact_id: other_contact&.id)
        nested_attributes.push(params)
      end
    end

    nested_attributes
  end

  def other_contacts_hash(locale, other_contact_attr, other_contact_id: nil)
    params = {
      "title_#{locale}": other_contact_attr[:title],
      "content_#{locale}": other_contact_attr[:content]
    }

    if other_contact_id.present?
      # updating
      params[:id] = other_contact_id
    end

    params
  end
end

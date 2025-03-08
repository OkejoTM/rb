class Parser::Operation::Contact::AttributesForUpdate < Parser::Operation::Contact::Base
  map :get_attributes
  step :check_attributes
  map :mark_delete
  map :add
  map :finish

  def get_attributes(agency:, attributes:)
    parsed_attributes = attributes.slice(:contacts_ru, :contacts_en)

    {
      agency: agency,
      attributes: attributes,
      contacts: agency&.contacts || [],
      parsed_attributes: parsed_attributes,
      contacts_attributes: []
    }
  end

  def check_attributes(contacts:, parsed_attributes:, **rest)

    if contacts.blank? && locales.all? { |locale| parsed_attributes[:"contacts_#{locale}"].blank? }
      return Failure(rest.slice(:agency, :attributes))
    end

    Success(
      contacts: contacts,
      parsed_attributes: parsed_attributes,
      **rest
    )
  end

  def mark_delete(contacts:, parsed_attributes:, contacts_attributes:, **rest)
    for_delete = mark_for_delete_contacts(contacts, parsed_attributes)

    if for_delete.present?
      contacts_attributes.concat(for_delete)
    end

    {
      contacts: contacts,
      parsed_attributes: parsed_attributes,
      contacts_attributes: contacts_attributes,
      **rest
    }
  end

  def add(contacts:, parsed_attributes:, contacts_attributes:, **rest)
    new_contacts = add_not_existed_contacts(locales, parsed_attributes, contacts: contacts)

    if new_contacts.present?
      contacts_attributes.concat(new_contacts)
    end

    {
      contacts: contacts,
      parsed_attributes: parsed_attributes,
      contacts_attributes: contacts_attributes,
      **rest
    }
  end

  def finish(agency:, attributes:, contacts_attributes:, **rest)

    if contacts_attributes.present?
      attributes[:contacts_attributes] = contacts_attributes
    end

    { agency: agency, attributes: attributes }
  end
end

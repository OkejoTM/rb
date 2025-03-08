class Parser::Operation::OtherContact::AttributesForUpdate < Parser::Operation::OtherContact::Base
  map :get_attributes
  step :check_attributes
  map :mark_delete
  map :update
  map :finish

  def get_attributes(agency:, attributes:)
    parsed_attributes = attributes.slice(:other_contacts_ru, :other_contacts_en)

    {
      agency: agency,
      attributes: attributes,
      agency_other_contacts: agency&.agency_other_contacts || [],
      parsed_attributes: parsed_attributes,
      agency_other_contacts_attributes: []
    }
  end

  def check_attributes(agency_other_contacts:, parsed_attributes:, **rest)

    if agency_other_contacts.blank? && locales.all? { |locale| parsed_attributes[:"other_contacts_#{locale}"].blank? }
      return Failure(agency: rest[:agency], attributes: rest[:attributes])
    end

    Success(
      agency_other_contacts: agency_other_contacts,
      parsed_attributes: parsed_attributes,
      **rest
    )
  end

  def mark_delete(agency_other_contacts:, parsed_attributes:, agency_other_contacts_attributes:, **rest)
    for_delete = mark_for_delete_other_contacts(locales, agency_other_contacts, parsed_attributes)

    if for_delete.present?
      agency_other_contacts_attributes.concat(for_delete)
    end

    {
      agency_other_contacts: agency_other_contacts,
      parsed_attributes: parsed_attributes,
      agency_other_contacts_attributes: agency_other_contacts_attributes,
      **rest
    }
  end

  def add(agency_other_contacts:, parsed_attributes:, agency_other_contacts_attributes:, **rest)
    new_agency_other_contacts = add_other_contacts(locales, parsed_attributes)

    if new_agency_other_contacts.present?
      agency_other_contacts_attributes.concat(new_agency_other_contacts)
    end

    {
      agency_other_contacts: agency_other_contacts,
      parsed_attributes: parsed_attributes,
      agency_other_contacts_attributes: agency_other_contacts_attributes,
      **rest
    }
  end

  def update(agency_other_contacts:, parsed_attributes:, agency_other_contacts_attributes:,  **rest)
    updated_agency_other_contacts = update_other_contacts(locales, parsed_attributes, agency_other_contacts)

    if updated_agency_other_contacts.present?
      agency_other_contacts_attributes.concat(updated_agency_other_contacts)
    end

    {
      agency_other_contacts: agency_other_contacts,
      parsed_attributes: parsed_attributes,
      agency_other_contacts_attributes: agency_other_contacts_attributes,
      **rest
    }
  end

  def finish(agency:, attributes:, agency_other_contacts_attributes:, **rest)

    if agency_other_contacts_attributes.present?
      attributes[:agency_other_contacts_attributes] = agency_other_contacts_attributes
    end

    { agency: agency, attributes: attributes }
  end
end

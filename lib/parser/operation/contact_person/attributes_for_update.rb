class Parser::Operation::ContactPerson::AttributesForUpdate < Parser::Operation::ContactPerson::Base
  map :get_attributes
  step :check_attributes
  map :mark_delete
  map :add
  map :update
  map :finish

  def get_attributes(agency:, attributes:)
    parsed_attributes = attributes.slice(:contact_people_ru, :contact_people_en)

    {
      agency: agency,
      attributes: attributes,
      contact_people: agency&.contact_people || [],
      parsed_attributes: parsed_attributes,
      contact_people_attributes: []
    }
  end

  def check_attributes(contact_people:, parsed_attributes:, **rest)

    if locales.all? { |locale| parsed_attributes.has_key?(:"contact_people_#{locale}") }
      return Failure(agency: rest[:agency], attributes: rest[:attributes])
    end

    if contact_people.blank? && locales.all? { |locale| parsed_attributes[:"contact_people_#{locale}"].blank? }
      return Failure(agency: rest[:agency], attributes: rest[:attributes])
    end

    Success(
      contact_people: contact_people,
      parsed_attributes: parsed_attributes,
      **rest
    )
  end

  def mark_delete(contact_people:, parsed_attributes:, contact_people_attributes:, **rest)
    for_delete = mark_for_delete_contact_people(contact_people, contact_people_attributes, locales)

    if for_delete.present?
      contact_people_attributes.concat(for_delete)
    end

    {
      contact_people: contact_people,
      parsed_attributes: parsed_attributes,
      contact_people_attributes: contact_people_attributes,
      **rest
    }
  end

  def add(contact_people:, parsed_attributes:, contact_people_attributes:, **rest)
    new_contact_people = add_new_contact_people(locales, parsed_attributes, contact_people: contact_people)

    if new_contact_people.present?
      contact_people_attributes.concat(new_contact_people)
    end

    {
      contact_people: contact_people,
      parsed_attributes: parsed_attributes,
      contact_people_attributes: contact_people_attributes,
      **rest
    }
  end

  def update(contact_people:, parsed_attributes:, contact_people_attributes:,  **rest)
    updated_contact_people = update_contact_people(locales, parsed_attributes, contact_people)

    if updated_contact_people.present?
      contact_people_attributes.concat(updated_contact_people)
    end

    {
      contact_people: contact_people,
      parsed_attributes: parsed_attributes,
      contact_people_attributes: contact_people_attributes,
      **rest
    }
  end

  def finish(agency:, attributes:, contact_people_attributes:, **rest)

    if contact_people_attributes.present?
      attributes[:contact_people_attributes] = contact_people_attributes
    end

    { agency: agency, attributes: attributes }
  end
end

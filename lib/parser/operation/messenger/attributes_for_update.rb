class Parser::Operation::Messenger::AttributesForUpdate < Parser::Operation::Messenger::Base
  map :get_attributes
  step :check_attributes
  map :mark_delete
  map :add_not_existed
  map :finish

  def get_attributes(agency:, attributes:)
    {
        agency: agency,
        attributes: attributes,
        messengers: agency&.messengers || [],
        parsed_attributes: attributes[:messengers],
        messengers_attributes: []
    }
  end

  def check_attributes(messengers:, parsed_attributes:, **rest)
    parsed_attributes = parsed_attributes&.first&.fetch(:content, []) || []

    if messengers.blank? && parsed_attributes.blank?
      return Failure(agency: rest[:agency], attributes: rest[:attributes])
    end

    Success(
        messengers: messengers,
        parsed_attributes: parsed_attributes,
        **rest
    )
  end

  def mark_delete(messengers:, parsed_attributes:, messengers_attributes:, **rest)
    for_delete = mark_for_delete_messengers(messengers, parsed_attributes)

    if for_delete.present?
      messengers_attributes.concat(for_delete)
    end

    {
        messengers: messengers,
        parsed_attributes: parsed_attributes,
        messengers_attributes: messengers_attributes,
        **rest
    }
  end

  # Нам в принципе не нужно обновлять номера, достаточно удалить те,
  # которые пропали и добавить новые, которых нет
  def add_not_existed(messengers:, parsed_attributes:, messengers_attributes:,  **rest)
    updated_contact_people = add_new_messengers(parsed_attributes, messengers: messengers)

    if updated_contact_people.present?
      messengers_attributes.concat(updated_contact_people)
    end

    {
        messengers: messengers,
        parsed_attributes: parsed_attributes,
        messengers_attributes: messengers_attributes,
        **rest
    }
  end

  def finish(agency:, attributes:, messengers_attributes:, **rest)

    if messengers_attributes.present?
      attributes[:messengers_attributes] = messengers_attributes
    end

    { agency: agency, attributes: attributes }
  end
end

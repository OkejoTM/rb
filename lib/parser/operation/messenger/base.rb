class Parser::Operation::Messenger::Base < Parser::Operation::BaseAttributesFor

  # Помечает контакты +messengers+ не найденные в +messengers_attrs+ на удаление
  # @param [Array<Messenger>] messengers
  # @param [Hash] messengers_attrs
  # @return [Array<Hash>]
  def mark_for_delete_messengers(messengers, messengers_attrs)
    mark_for_delete(messengers, messengers_attrs) do |messenger, messenger_attr|
      messenger.phone == messenger_attr[:phone] && messenger.messenger_type.title.in?(messenger_attr[:type])
    end
  end

  # Добавляет не существующие мессенджеры
  # @param [Array<Messenger>] messengers
  # @param [Hash] messengers_attrs
  # @return [Array<Hash>]
  def add_new_messengers(messengers_attrs, messengers: [])
    m_types = MessengerType.all.to_a
    nested_attributes = []

    messengers_attrs.each do |m|
      types = m[:type]
      phone = m[:phone]

      types.each do |type|
        next if messengers.any? { |messenger| phone == messenger.phone && messenger.messenger_type.title == type }

        params = messenger_hash(type, phone, m_types)

        nested_attributes.push(params)
      end
    end

    nested_attributes
  end

  def messenger_hash(type, phone, m_types)

    m_type = m_types.find { |mt| mt.title == type }
    m_type =
        if m_type.blank?
          { messenger_type_attributes: { title: type } }
        else
          { messenger_type_id: m_type.id }
        end

    {
        phone: phone,
        **m_type
    }
  end
end

class Parser::Operation::BaseCreate < Parser::Operation::Base
  define_message :no_pictures, "Property <%s> is not added. There is no pictures for this property"

  # Создает ли операция новую сущность?
  def new?
    true
  end

  # Шаг завершающий операцию и сохраняющий данные в БД
  # @param [Hash] attributes
  # @return [Monad]
  def save(attributes:)
    permitted_attrs = permitted_params(attributes)

    entity = subject_class.new(permitted_attrs)

    if entity.save
      Success(entity)
    else
      Failure(entity: entity, errors: entity&.errors&.messages)
    end
  end
end

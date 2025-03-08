class Parser::Operation::BaseUpdate < Parser::Operation::Base

  # Создает ли операция новую сущность?
  def new?
    false
  end

  # Шаг завершающий операцию и сохраняющий данные в БД
  # @param [Hash] attributes
  # @param [ActiveRecord] entity Сущность которую нужно обновить
  # @return [Monad] Success: ActiveRecord, Failure: { entity: ActiveRecord, errors: Array }
  def save(entity:, attributes:)
    permitted_attrs = permitted_params(attributes)

    if entity.update(permitted_attrs)
      Success(entity)
    else
      Failure(entity: entity, errors: entity&.errors&.messages)
    end
  end

  # Ищет подходящую парсингу сущность в БД
  # @param [Hash] attributes
  # @param [ActiveRecordRelation] relation массив в котором ищется сущность
  # @return [Monad] Success: { entity: ActiveRecord, attributes: Hash }, Failure: String
  def find_existing(attributes, relation:)
    entity = relation.find { |entity| existing_record_condition(entity, attributes) }

    if entity.present?
      Success(entity: entity, attributes: attributes)
    else
      Failure(find_existing_failure_msg)
    end
  end

  protected

    # Правило по которому ищется запись в +find_existing+
    # @param [ActiveRecord] entity
    # @param [Hash] attributes
    # @return [Boolean]
    def existing_record_condition(entity, attributes)
      raise NotImplementedError
    end

    # @return [String] Сообщение о провале поиска
    def find_existing_failure_msg
      raise NotImplementedError
    end
end

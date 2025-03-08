class Parser::Operation::BaseAttributesFor < Parser::Operation::Base

  # Формирует массив сущностей, который необходимо удалить (те, которые не нашлись в массиве +entities_attrs+)
  # @param [Array<ActiveRecord>] entities_list массив существующих сущностей
  # @param [Array<Hash>] entities_attrs массив который был получен в результате парсинга
  # @param [Proc] condition_block блок, который определяет правило по которому сущность и данные парсинга совпадают
  # @return [Array<Hash>]
  def mark_for_delete(entities_list, entities_attrs, &condition_block)
    nested_attributes = []

    entities_list.each do |entity|
      not_exist = entities_attrs.none? do |entity_attr|
        condition_block.call(entity, entity_attr)
      end

      if not_exist
        nested_attributes.push(id: entity.id, _destroy: true)
      end
    end

    nested_attributes
  end
end

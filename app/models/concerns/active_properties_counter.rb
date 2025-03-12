module ActivePropertiesCounter
  extend ActiveSupport::Concern

  included do
    scope :has_active_and_moderated_property, -> { where("#{self.table_name}.active_and_moderated_properties_count > 0") }
    scope :has_active_property, -> { where("#{self.table_name}.active_properties_count > 0") }
    scope :has_property, -> { where("#{self.table_name}.properties_count > 0") }

    after_save :update_counter_cache
  end

  # Обновляет количество активной и модерированной недвижимости
  # @return [Boolean] успешность обновления
  # @example
  #   Country.first.update_active_properties_counter
  def update_active_properties_counter
    update_column(:active_properties_count, properties.active.count)
  end

  def update_active_and_moderated_properties_counter
    update_column(:active_and_moderated_properties_count, properties.active_and_moderated.count)
  end

  def update_counter_cache
    self.class.reset_counters(self.id, :properties_count)
    self.update_active_properties_counter
    self.update_active_and_moderated_properties_counter
  end
end

module Filterable
  extend ActiveSupport::Concern
  included do
    class_attribute :params_for_filter

    class << self
      # Фильтрует объекты
      # @param filtering_objects [Filterable] список объектов для фильтрации
      # @param params [Hash] список параметров фильтрации
      # @return [Filterable] список отфильтрованных объектов
      # @example
      #   City.filter
      def filter(filtering_objects, params)
        params.slice(*self.params_for_filter).each do |key, value|
          filtering_objects =
              if value.present? && value != 'on'
                filtering_objects.public_send(key, value)
              elsif value.present?
                filtering_objects.public_send(key)
              else
                filtering_objects
              end
        end
        filtering_objects
      end

      # Устанавливает параметры для фильтра
      # @param attrs [Hash] список параметров
      def filter_params(*attrs)
        self.params_for_filter ||= attrs
      end
    end
  end
end

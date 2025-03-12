module QueryModule
  extend ActiveSupport::Concern

  included do
    class_attribute :condition, :fields_count

    scope :query, -> (query) do
      where(self.condition, *Array.new(self.fields_count, "%#{query}%")) if query.present?
    end

    class << self
      # Задает список полей +fields+ модели Active Record,
      # по которым будет производиться текстовый поиск при вызове скоупа +query+.
      # @param fields [Array] список полей, по которым будет производиться текстовый поиск
      # @param options [Hash] параметры запроса:
      # * <tt>:case_sensitive</tt> - регистрочувствительность. Может быть +true+ или +false+ (по-умолчанию +false+)
      # @example
      #   query_fields :name_ru, :name_en, case_sensitive: false
      def query_fields(*fields, **options)
        like = options.fetch(:case_sensitive, false) ? 'LIKE' : 'ILIKE'

        self.fields_count ||= fields.count
        self.condition ||= fields.map! { |field| " #{field} #{like} ?" }.join(' OR')
      end
    end
  end
end

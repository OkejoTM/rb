class BaseSearch

  # Имя модели, в которой осуществляется поиск
  # @return [String] имя модели
  # @example
  #   BaseSearch.new(City, "Испания", [:title_en, :title_ru]).search_name
  def search_name
    @model_class.name
  end

  ANALYZER = "RUS_EN_key_analyzer"

  # Инициализирует поиск
  # @param model_class [Model] модель, в которой осуществляется поиск
  # @param query [String] поисковый запрос
  # @param fields [Array] список полей модели, в которых осуществлять поиск
  # @return [BaseSearch] поиск
  # @example
  #   BaseSearch.new(City, "Испания", [:title_en, :title_ru])
  # @see SearchableRecord
  def initialize(model_class, query, fields)
    if model_class.ancestors.select { |c| c.name == "SearchableRecord" }.blank?
      raise "I'm not SearchableRecord! Add 'include SearchableRecord' for model #{@model_class.name}."
    end

    @model_class = model_class
    @fields = fields
    @query = query
    @invert_query = Country.searchkick_index.tokens(@query, analyzer: ANALYZER).join(" ")
  end

  # Вызывает поиск по модели
  # @return [Model] найденный объекты
  # @example
  #   searcher_city = BaseSearch.new(City, "Испания", [:title_en, :title_ru])
  #   searcher_city.call
  def call
    limit_count = 4
    locations = search_location(@query, limit_count)
    locations.concat(search_location(@invert_query, limit_count))

    locations
  end

private
  # Поиск по модели
  # @param query [String] поисковый запрос
  # @param limit_count [Integer] предел поиска
  # @return [Array] найденные объекты
  # @private
  # @example
  #   BaseSearch.new(City, "Испания", [:title_en, :title_ru]).search_location("Испания", 4)
  def search_location (query, limit_count)
    locations = @model_class.search(query, fields: @fields, suggest: true, limit: limit_count, match: :word_start, where: { coming_soon: false, is_active: true }, operator: "or")
    locations.suggestions
    locations.to_a
  end
end

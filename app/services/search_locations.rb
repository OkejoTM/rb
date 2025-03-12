# module Services
class SearchLocations

  def initialize(query)
    @query = query
  end

  # Осуществляет поиск локации по заданному запросу
  # Если ничего не найдено, устанавливаются переданные значения по-умолчанию
  # @param [Hash] options значения по-умолчанию для локаций
  # @option :default_countries [Array] - список стран по-умолчанию
  # @option :default_regions [Array] - список регионов по-умолчанию
  # @option :default_cities [Array] - список городов по-умолчанию
  # @return [Hash<String, <Array>>] список локаций со ссылками на них
  def perform(**options)
    default_countries = options.fetch(:default_countries, nil)
    default_regions = options.fetch(:default_regions, nil)
    default_cities = options.fetch(:default_cities, nil)

    searcher_city = BaseSearch.new(City, @query, [:title_en, :title_ru])
    searcher_region = BaseSearch.new(Region, @query, [:title_en, :title_ru])
    searcher_country = BaseSearch.new(Country, @query, [:title_en, :title_ru])

    result = {}
    result_cities = searcher_city.call
    result_regions = searcher_region.call
    result_countries = searcher_country.call

    result_cities = default_cities if result_cities.blank? && default_cities.present?
    result_regions = default_regions if result_regions.blank? && default_regions.present?
    result_countries = default_countries if result_countries.blank? && default_countries.present?

    result["Cities"] = []
    result["Regions"] = []
    result["Countries"] = []
    result["links"] = {}

    result_cities.each do |search|
      presenter = City::Presenter.new(search)
      result["Cities"] << presenter.full_title
      result["links"][presenter.full_title] = presenter.seo_path
    end
    result_regions.each do |search|
      presenter = Region::Presenter.new(search)
      result["Regions"] << presenter.full_title
      result["links"][presenter.full_title] = presenter.seo_path
    end
    result_countries.each do |search|
      presenter = Country::Presenter.new(search)
      result["Countries"] << presenter.full_title
      result["links"][presenter.full_title] = presenter.seo_path
    end
    result
  end
end
# end

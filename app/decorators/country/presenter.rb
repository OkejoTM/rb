class Country::Presenter < BasicPresenter
  extend Memoist

  # Полное название страны
  # @return [String] полное название страны
  # @example
  #   Country::Presenter.new(Country.first).full_title
  def full_title
    title
  end

  # Подзаголовок страны
  # @return [String] подзаголовок страны
  # @example
  #   Country::Presenter.new(Country.first).subtitle
  def subtitle
    helpers.page_count_objects(self.active_and_moderated_properties_count)
  end

  # Полное название города в предложном падеже (в Елгаве, Латвия)
  # @return [String]
  def full_name_locative
    self.title_prepositional
  end

  # Важные регионы страны
  # @return [Region] список регионов
  # @example
  #   Country::Presenter.new(Country.first).important_regions
  # @see Region
  def important_regions
    self.regions.visible.order(is_popular: :desc, active_and_moderated_properties_count: :desc)
  end

  # Важные города страны
  # @return [Cities] список важных городов
  # @example
  #   Country::Presenter.new(Country.first).important_cities
  # @see City
  def important_cities
    self.cities.visible.preload(:region).order(is_popular: :desc, active_and_moderated_properties_count: :desc)
  end

  memoize :full_title, :subtitle, :full_name_locative, :important_regions, :important_cities
end

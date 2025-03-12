class City::Presenter < BasicPresenter
  extend Memoist

  # Полное название города
  # @return [String] полное название города
  # @example
  #   City::Presenter.new(City.first).full_title
  def full_title
    "#{title}, #{region.title}, #{region.country.title}"
  end

  # Подзаголовок города
  # @return [String] подзаголовок города
  # @example
  #   City::Presenter.new(City.first).subtitle
  def subtitle
    helpers.page_count_objects(self.active_and_moderated_properties_count)
  end

  # Полное название города в предложном падеже (в Елгаве, Латвия)
  # @return [String]
  def full_name_locative
    "#{self.title_prepositional}, #{country.title}"
  end

  memoize :full_title, :subtitle, :full_name_locative
end

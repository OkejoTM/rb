class Region::Presenter < BasicPresenter
  extend Memoist

  # Полное название региона
  # @return [String] полное название региона
  # @example
  #   City::Presenter.new(City.first).full_title
  def full_title
    "#{title}, #{country.title}"
  end

  # Подзаголовок региона
  # @return [String] подзаголовок региона
  # @example
  #   Region::Presenter.new(Region.first).subtitle
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

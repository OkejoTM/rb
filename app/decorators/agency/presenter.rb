class Agency::Presenter < BasicPresenter
  extend Memoist

  MAX_META_DESCRIPTION_LENGTH = 175

  # Сайт агентства
  # @return [String] сайт агентства
  # @example
  #   Agency::Presenter.new(Agency.first).website
  def website
    if super.present? && super.index(/http/) != 0
      "https://" + super
    else
      super
    end
  end

  # Содержимое тега meta_description
  # @return [String] описание
  # @example
  #   Agency::Presenter.new(Agency.first).meta_description
  def meta_description
    if super.present?
      super
    else
      if self.about.present?
        self.about[0..self.about&.rindex(".", MAX_META_DESCRIPTION_LENGTH) ||
            self.about&.rindex(/\s/, MAX_META_DESCRIPTION_LENGTH) || -1]
      else
        I18n.t('meta.agency_meta_description', full_name: self.name)
      end
    end
  end

  # Показывать ли в данной стране агентства
  def linked_to_disabled_countries?
    self.active_countries.exists?(show_agencies_on_website: false)
  end

  memoize :website, :meta_description, :linked_to_disabled_countries?
end

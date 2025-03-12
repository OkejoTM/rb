class Property::AutoNaming::Chalet < BasicPresenter

  extend Memoist

  def prefix
    # TODO учесть системы счисления. По-умолчанию метрическая
    if self.area.present?
      if self.area < 100
        I18n.t("property_chunks.prefix.#{genus}.cozy")
      elsif self.area >= 100 && self.area < 200
        I18n.t("property_chunks.prefix.#{genus}.spacious")
      elsif self.area >= 200
        I18n.t("property_chunks.prefix.#{genus}.fabulous")
      end
    else
      ''
    end
  end

  def room_count_str
    ''
  end

  def level_count_str
    if self.level_count.present? && self.level_count.in?(1..5)
      I18n.t("property_chunks.level_count.#{genus}.#{self.level_count}_story")
    else
      ''
    end
  end

  memoize :prefix, :room_count_str, :level_count_str

  private

    def genus
      'masculine'
    end
end

class Property::AutoNaming::House < BasicPresenter

  extend Memoist

  def prefix
    # TODO учесть системы счисления. По-умолчанию метрическая
    if self.area.present?
      if self.area < 150
        I18n.t("property_chunks.prefix.#{genus}.beautiful")
      elsif self.area >= 150 && self.area < 300
        I18n.t("property_chunks.prefix.#{genus}.magnificent")
      elsif self.area >= 300 && self.area < 500
        I18n.t("property_chunks.prefix.#{genus}.fabulous")
      elsif self.area >= 500
        I18n.t("property_chunks.prefix.#{genus}.gorgeous")
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

class Property::AutoNaming::Flat < BasicPresenter

  extend Memoist

  def prefix
    # TODO учесть системы счисления. По-умолчанию метрическая
    if self.area.present?
      if self.area < 50
        I18n.t("property_chunks.prefix.#{genus}.cozy")
      elsif self.area >= 50 && self.area < 150
        I18n.t("property_chunks.prefix.#{genus}.comfortable")
      elsif self.area >= 150
        I18n.t("property_chunks.prefix.#{genus}.gorgeous")
      end
    else
      ''
    end
  end

  def room_count_str
    if self.room_count.present? && self.room_count.in?(1..5)
      I18n.t("property_chunks.room_count.#{genus}.#{self.room_count}_room")
    else
      ''
    end
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
      'feminine'
    end
end

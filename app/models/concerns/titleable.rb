module Titleable
  # Возвращает название в зависимости от языка
  # @return [String] название
  # @example
  #   Country.first.title
  extend ActiveSupport::Concern
  included do
    include Localizable
    translate_fields :title
  end

  # Возвращает название в родительном падеже
  # @return [String] название в родительном падеже
  # @example
  #   Country.first.title_genitive
  def title_genitive
    case I18n.locale
      when :en
        title_genitive_en.presence || RussianInflect.inflect(title_en, :genitive)
      when :ru
        title_genitive_ru.presence || RussianInflect.inflect(title_ru, :genitive)
      else
        ""
    end
  end

  # Возвращает название в предложном падеже
  # @return [String] название в предложном падеже
  # @example
  #   Country.first.title_prepositional
  def title_prepositional
    case I18n.locale
      when :en
        title_prepositional_en.presence || "#{I18n.t('common.in')} #{RussianInflect.inflect(title_en, :prepositional)}"
      when :ru
        title_prepositional_ru.presence || "#{I18n.t('common.in')} #{RussianInflect.inflect(title_ru, :prepositional)}"
      else
        ""
    end
  end
end

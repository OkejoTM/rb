module Locationable
  extend ActiveSupport::Concern

  include Titleable
  # include SeoModule
  include Position
  include Filterable
  include ActivePropertiesCounter
  include UserstampModule
  include Localizable
  include SeoTemplatable
  include QueryModule
  include Decoratable

  MAX_DISTANCE_IN_GRAD = 360 * Math.sqrt(2)
  MAX_DISTANCE_IN_KM = 20000

  included do
    translate_fields :title, :title_genitive, :title_prepositional
    query_fields :title_ru, :title_en

    scope :active, -> { raise NotImplementedError }

    scope :popular, -> { where(is_popular: true) }
    scope :sort_location_by, -> (sort_name) { order(sort_name) }
    scope :has_not_locale, -> (locale) { case locale
                                           when "ru"
                                             where("title_ru IS NULL OR NOT (title_ru SIMILAR TO '%[\u0410-\u044f]%')")
                                           when "en"
                                             where(title_en: nil)
                                         end }

    scope :coming_soon, -> { where(coming_soon: true) }
    scope :visible, -> { active.has_active_and_moderated_property.where(coming_soon: false) }

    scope :without_translation, -> {
      where("title_ru = '' OR title_ru IS NULL OR
             title_en = '' OR title_en IS NULL OR
             title_genitive_ru = '' OR title_genitive_ru IS NULL OR
             title_genitive_en = '' OR title_genitive_en IS NULL OR
             title_prepositional_ru = '' OR title_prepositional_ru IS NULL OR
             title_prepositional_en = '' OR title_prepositional_en IS NULL")
    }

    validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' }
    validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' }
    validates :slug, uniqueness: true, slug: true
  end

  # Возвращает наименование локации на английском языке
  # @return [String] наименование локации на английском языке
  # @example
  #   Country.first.title_en
  def title_en
    super.presence || name
  end

  # Возвращает наименование локации на русском языке
  # @return [String] наименование локации на русском языке
  # @example
  #   Country.first.title_ru
  def title_ru
    super.presence || title_en
  end

  # Возвращает количество активной недвижимости
  # @return [String] количество активной недвижимости
  # @example
  #   Country.first.active_properties_count
  def active_properties_count
    super.presence || properties.active.count
  end

  # Количество актуальной (добавленной вручную или через интеграцию) недвижимости
  def actual_properties_count
    properties.active_and_moderated.not_fillers.count
  end

  # Процент актуальной (добавленной вручную или через интеграцию) недвижимости
  def actual_properties_percent
    if active_and_moderated_properties_count > 0
      actual_properties_count * 100 / active_and_moderated_properties_count
    else
      0
    end
  end
end

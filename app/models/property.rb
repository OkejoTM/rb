# == Schema Information
#
# Table name: properties
#
#  id                             :bigint           not null, primary key
#  additional_area_en             :text
#  additional_area_ru             :text
#  area                           :float
#  area_unit                      :integer
#  attributes_en                  :text
#  attributes_ru                  :text
#  autotranslated_description_de  :boolean          default(FALSE)
#  autotranslated_description_en  :boolean          default(FALSE)
#  building_year                  :date
#  city_name_en                   :string
#  city_name_ru                   :string
#  construction_phase             :integer          indexed
#  country_name_en                :string
#  country_name_ru                :string
#  created_by                     :integer
#  description_en                 :string
#  description_ru                 :string
#  description_three_en           :text
#  description_three_ru           :text
#  description_two_en             :text
#  description_two_ru             :text
#  energy_efficiency_type         :integer
#  external_link                  :string
#  for_sale                       :boolean          default(TRUE)
#  h1_en                          :string
#  h1_ru                          :string
#  is_active                      :boolean          default(FALSE)
#  is_filler                      :boolean          default(FALSE)
#  last_repair                    :date
#  latitude                       :float
#  longitude                      :float
#  meta_description_en            :string
#  meta_description_ru            :string
#  moderated                      :boolean          default(FALSE)
#  page_h1_en                     :string
#  page_h1_ru                     :string
#  page_title_en                  :string
#  page_title_ru                  :string
#  parsed                         :boolean          default(FALSE), not null
#  plot_area                      :float
#  plot_area_unit                 :integer
#  price_on_request               :boolean          default(FALSE)
#  region_name_en                 :string
#  region_name_ru                 :string
#  rent_price_per_day             :integer
#  rent_price_per_month           :integer
#  rent_price_per_week            :integer
#  rent_price_unit_per_day        :string
#  rent_price_unit_per_month      :string
#  rent_price_unit_per_week       :string
#  room_count                     :integer
#  sale_price                     :bigint           default(0)
#  sale_price_unit                :string
#  short_page_title_en            :string
#  short_page_title_ru            :string
#  studio                         :boolean          default(FALSE)
#  subtype_en                     :string
#  subtype_ru                     :string
#  to_airport                     :integer
#  to_airport_unit                :integer
#  to_beach                       :integer
#  to_beach_unit                  :integer
#  to_food_stores                 :integer
#  to_food_stores_unit            :integer
#  to_historical_city_center      :integer
#  to_historical_city_center_unit :integer
#  to_medical_facilities          :integer
#  to_medical_facilities_unit     :integer
#  to_metro_station               :integer
#  to_metro_station_unit          :integer
#  to_nearest_big_city            :integer
#  to_nearest_big_city_unit       :integer
#  to_railroad_station            :integer
#  to_railroad_station_unit       :integer
#  to_sea                         :integer
#  to_sea_unit                    :integer
#  to_ski_lift                    :integer
#  to_ski_lift_unit               :integer
#  to_state_border                :integer
#  to_state_border_unit           :integer
#  updated_by                     :integer
#  video_link                     :string
#  created_at                     :datetime         not null, indexed
#  updated_at                     :datetime         not null
#  agency_id                      :bigint           indexed
#  city_id                        :bigint           indexed
#  country_id                     :bigint           indexed
#  property_type_id               :bigint           indexed
#  region_id                      :bigint           indexed
#

class Property < ApplicationRecord
  #@!group Стадии строительства
  # Новый дом
  CONSTRUCTION_PHASE_NEW = 0
  # Строящийся объект
  CONSTRUCTION_PHASE_OFF_PLAN = 1
  # Вторичная недвижимость
  CONSTRUCTION_PHASE_RESALE = 2
  #@!endgroup

  MAX_YEAR = 2100
  MAX_LEVELS_COUNT = 200
  MAX_BEDROOMS_COUNT = 300
  MAX_BATHROOMS_COUNT = 300
  MAX_ROOMS_COUNT = 300

  include SeoModule
  include UserstampModule
  include Position
  include Filterable
  include Localizable
  include Pictureable
  include Priceable
  include Moderatable
  include ScopeModule
  include Decoratable
  include Translatable

  serialize :attributes_ru, Hash
  serialize :attributes_en, Hash
  translate_fields :description, :short_page_title

  filter_params :commercial, :residential, :land,
                :country_id, :region_id, :city_id, :agency_id, :location_type_id,
                :location_type_ids,
                :active, :moderated, :moderated_choice, :active_choice,
                :type, :types_group, :bedrooms, :bathrooms, :room_count, :studio,
                :level_from, :level_to, :not_last_level,
                :level_count_from, :level_count_to,
                :with_price, :price_from, :price_to,
                :area_from, :area_to,
                :plot_area_from, :plot_area_to,
                :for_sale, :for_rent,
                :rentable_area_from, :rentable_area_to,
                :rental_yield_per_year_from, :rental_yield_per_year_to,
                :rental_yield_per_month_from, :rental_yield_per_month_to,
                :min_absolute_income_from, :min_absolute_income_to,
                :min_amount_of_own_capital_from, :min_amount_of_own_capital_to,
                :construction_phase,
                :by_tags,
                :building_year_from, :building_year_to,
                :last_repair_from, :last_repair_to,
                :sort_by_price, :sort_property_by,
                :property_supertype,
                :property_supertype_id, :property_type_group_id, :property_type_id,
                :short_description

  belongs_to :country, optional: true, counter_cache: true
  belongs_to :region, optional: true, counter_cache: true
  belongs_to :city, optional: true, counter_cache: true

  belongs_to :agency, counter_cache: true
  belongs_to :property_type, optional: true
  has_one :property_type_group, through: :property_type
  has_one :property_supertype, through: :property_type
  has_and_belongs_to_many :location_types, optional: true
  has_and_belongs_to_many :property_tags
  accepts_nested_attributes_for :property_tags

  ENERGY_EFFICIENCY_TYPES = {
      'A++': 0,
      'A+': 1,
      'A': 2,
      'B+': 3,
      'B': 4,
      'C+': 5,
      'C': 6,
      'C-': 7,
      'D': 8,
      'E': 9,
      'F': 10,
      'G': 11
  }.freeze

  enum energy_efficiency_type: ENERGY_EFFICIENCY_TYPES, _suffix: true

  # COMMERCIAL PROPERTY
  has_one :commercial_property_attribute, dependent: :destroy
  delegate :rentable_area, :rentable_area_unit,
           :rental_yield_per_year, :rental_yield_per_year_unit,
           :rental_yield_per_month, :rental_yield_per_month_unit,
           :min_absolute_income, :min_amount_of_own_capital,
           to: :commercial_property_attribute, allow_nil: true
  accepts_nested_attributes_for :commercial_property_attribute, allow_destroy: true


  # NONCOMMERCIAL PROPERTY
  has_one :noncommercial_property_attribute, dependent: :destroy
  delegate :level, :level_count,
           :bathroom_count, :bedroom_count,
           to: :noncommercial_property_attribute, allow_nil: true
  accepts_nested_attributes_for :noncommercial_property_attribute, allow_destroy: true

  scopes_with_value :country_id, :region_id, :city_id, :agency_id, :property_type_id,
                    :construction_phase

  scope :have_full_location, -> { where('NOT (country_id IS NULL OR region_id IS NULL OR city_id IS NULL)') }

  scope :active, -> { joins(:agency).where("properties.is_active = ? AND agencies.is_active = ?", true, true) }
  scope :inactive, -> { joins(:agency).where("properties.is_active = ? OR agencies.is_active = ?", false, false) }

  scope :active_choice, -> (option) {
    if option.present?
      if option == 'true'
        active
      elsif option == 'false'
        inactive
      end
    end
  }

  scope :active_and_moderated, -> { active.moderated }
  scope :with_associations, -> { preload(:agency, :country, :region, :city, :pictures,
                                         :commercial_property_attribute, :noncommercial_property_attribute,
                                         :property_type, :location_types) }

  scope :new_building, -> { where(construction_phase: Property::CONSTRUCTION_PHASE_NEW) }
  scope :resale, -> { where(construction_phase: Property::CONSTRUCTION_PHASE_RESALE) }
  scope :off_plan, -> { where(construction_phase: Property::CONSTRUCTION_PHASE_OFF_PLAN) }

  scope :by_tags, -> (tag_ids) {
    if tag_ids.present?
      joins(:property_tags).where(property_tags: { id: tag_ids })
    end
  }


  scope :level_from, -> (count) {
    if count.to_i.between?(1, MAX_LEVELS_COUNT)
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.level >= ?", count)
    end
  }

  scope :level_to, -> (count) {
    if count.to_i.between?(1, MAX_LEVELS_COUNT)
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.level <= ?", count)
    end
  }

  scope :not_last_level, -> {
    joins(:noncommercial_property_attribute)
        .where("noncommercial_property_attributes.level < noncommercial_property_attributes.level_count")
  }

  scope :level_count_from, -> (count) {
    if count.to_i.between?(1, MAX_LEVELS_COUNT)
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.level_count >= ?", count)
    end
  }

  scope :level_count_to, -> (count) {
    if count.to_i.between?(1, MAX_LEVELS_COUNT)
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.level_count <= ?", count)
    end
  }

  # TODO
  scope :bedrooms, -> (count) {
    if count.to_i == 5
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.bedroom_count >= ?", count)
    elsif count.to_i.between?(1, MAX_BEDROOMS_COUNT)
      joins(:noncommercial_property_attribute)
          .where(noncommercial_property_attributes: { bedroom_count: count })
    end
  }

  # TODO
  scope :bathrooms, -> (count) {
    if count.to_i == 5
      joins(:noncommercial_property_attribute)
          .where("noncommercial_property_attributes.bathroom_count >= ?", count)
    elsif count.to_i.between?(1, MAX_BATHROOMS_COUNT)
      joins(:noncommercial_property_attribute)
          .where(noncommercial_property_attributes: { bathroom_count: count })
    end
  }

  # TODO
  scope :room_count, -> (count) {
    if count.to_i == 5
      where("room_count >= ?", count)
    elsif count.to_i.between?(1, MAX_ROOMS_COUNT)
      where(room_count: count)
    elsif count.to_i == 0
      where(studio: true)
    end
  }

  scope :type, -> (type_id) {
    if type_id.to_i > 0
      joins(:property_type).where(property_type: type_id)
    end
  }

  scope :types_group, -> (type_id) { property_type_group_id(type_id) }


  scope :with_price, -> { where.not(sale_price: [nil, 0]) }

  scope :price_from, -> (price) {
    where("sale_price >= ?", price) if price.to_i > 0
  }

  scope :price_to, -> (price) {
    where("sale_price <= ?", price) if price.to_i > 0
  }


  scope :area_from, -> (area) {
    where("area >= ?", area) if area.to_i > 0
  }

  scope :area_to, -> (area) {
    where("area <= ?", area) if area.to_i > 0
  }


  scope :plot_area_from, -> (area) {
    where("plot_area >= ?", area) if area.to_i > 0
  }

  scope :plot_area_to, -> (area) {
    where("plot_area <= ?", area) if area.to_i > 0
  }


  scope :rentable_area_from, -> (area) {
    if area.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rentable_area >= ?", area)
    end
  }

  scope :rentable_area_to, -> (area) {
    if area.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rentable_area <= ?", area)
    end
  }


  scope :rental_yield_per_year_from, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rental_yield_per_year >= ?", value)
    end
  }

  scope :rental_yield_per_year_to, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rental_yield_per_year <= ?", value)
    end
  }


  scope :rental_yield_per_month_from, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rental_yield_per_month >= ?", value)
    end
  }

  scope :rental_yield_per_month_to, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.rental_yield_per_month <= ?", value)
    end
  }


  scope :min_absolute_income_from, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.min_absolute_income >= ?", value)
    end
  }

  scope :min_absolute_income_to, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.min_absolute_income <= ?", value)
    end
  }


  scope :min_amount_of_own_capital_from, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.min_amount_of_own_capital >= ?", value)
    end
  }

  scope :min_amount_of_own_capital_to, -> (value) {
    if value.to_i > 0
      joins(:commercial_property_attribute).where("commercial_property_attributes.min_amount_of_own_capital <= ?", value)
    end
  }


  scope :building_year_from, -> (year) {
    where("building_year >= ?", Date.new(year.to_i)) if year.to_i.between?(0, MAX_YEAR)
  }

  scope :building_year_to, -> (year) {
    where("building_year <= ?", Date.new(year.to_i)) if year.to_i.between?(0, MAX_YEAR)
  }


  scope :last_repair_from, -> (year) {
    where("last_repair >= ?", Date.new(year.to_i)) if year.to_i.between?(0, MAX_YEAR)
  }

  scope :last_repair_to, -> (year) {
    where("last_repair <= ?", Date.new(year.to_i)) if year.to_i.between?(0, MAX_YEAR)
  }

  scope :location_type_id, -> (id) {
    if id.to_i > 0
      joins(:location_types).where(location_types: { id: id })
    end
  }

  scope :location_type_ids, -> (ids) {
    joins(:location_types).where(location_types: { id: ids })
  }

  scope :for_sale, -> { where(for_sale: true) }
  scope :for_rent, -> { where(for_sale: false) }

  # Возвращает коммерческую недвижимость
  # @return [Property] список коммерческой недвижимости
  # @example
  #   Property.commercial
  # @see PropertySupertype
  scope :commercial, -> { where(property_type_id: PropertySupertype.find(PropertySupertype::COMMERCIAL).property_type_ids) }

  # Возвращает жилую недвижимость
  # @return [Property] список жилой недвижимости
  # @example
  #   Property.residential
  # @see PropertySupertype
  scope :residential, -> { where(property_type_id: PropertySupertype.find(PropertySupertype::RESIDENTIAL).property_type_ids) }

  # Возвращает земляные участки
  # @return [Property] список земляных участков
  # @example
  #   Property.land
  # @see PropertySupertype
  scope :land, -> { where(property_type_id: PropertySupertype.find(PropertySupertype::LAND).property_type_ids) }

  scope :property_supertype, -> (property_supertype_slug) { where(property_type_id:
                                                                      PropertySupertype.by_slug(property_supertype_slug).property_type_ids) }

  scope :property_supertype_id, -> (property_supertype_id) { where(property_type_id:
                                                                       PropertySupertype.find(property_supertype_id).property_type_ids) }

  scope :property_type_group_id, -> (property_type_group_id) {
    if property_type_group_id.to_i > 0
      where(property_type_id:
                PropertyTypeGroup.find(property_type_group_id).property_type_ids)
    end
  }

  scope :parsed, -> { where(parsed: true) }
  scope :handmade, -> { where(parsed: false) }

  #@!group Типы сортировки
  # по умолчания
  SORT_DEFAULT = 0
  # по возрастанию цены
  SORT_PRICE_LOW_TO_HIGH = 1
  # по убыванию цены
  SORT_PRICE_HIGH_TO_LOW = 2
  #@!endgroup

  scope :sort_by_price, -> (sort_type) {
    if sort_type.to_i == SORT_PRICE_LOW_TO_HIGH
      with_price.order(sale_price: :asc)
    elsif sort_type.to_i == SORT_PRICE_HIGH_TO_LOW
      with_price.order(sale_price: :desc)
    end
  }

  scope :sort_property_by, -> (sort_name) { order(sort_name) }

  MIN_DESCRIPTION_LENGTH = 100

  scope :short_description, -> { where("LENGTH(description_ru) < ? OR LENGTH(description_en) < ?",
                                       MIN_DESCRIPTION_LENGTH,
                                       MIN_DESCRIPTION_LENGTH) }

  scope :fillers, -> { where(is_filler: true) }
  scope :not_fillers, -> { where(is_filler: false) }

  validates :agency_id, presence: true

  after_destroy :update_counter_cache
  after_save :update_counter_cache

  class << self
    # Доля недвижимости, требующей перевода
    # @param [Symbol] lang - язык, для которого нужно определить долю переведенной недвижимости
    # @return [Integer]
    def for_translation_part(lang)
      source_lang = :ru # Пока переводим только с русского на другие языки
      properties_can_be_translated = Property.active.where.not("description_#{source_lang}": '')
      translated_properties = properties_can_be_translated
                                .where("autotranslated_description_#{lang}": true)
      translated_properties.count * 100 / properties_can_be_translated.count
    end
  end

  # URL к недвижимости
  # @return [String] URL к недвижимости
  # @example
  #   Property.first.seo_path
  def seo_path(format: nil)
    location = city || region || country
    return '' if location.blank?
    path = "#{location.seo_path}/#{self.id}"
    path += ".#{format}" if format.present?

    path
  end

  # URL к изображениям недвижимости
  # @return [Array] URL к изображениям недвижимости
  # @example
  #   Property.first.pics_urls
  def pics_urls
    res = []
    pictures.each do |picture|
      if picture.pic.present?
        res << ((external_link.present? && external_link.match?(/homesoverseas/)) ? picture.cropped_picture_url : picture.pic.url)
      end
    end
    res
  end

  # URL к изображениям недвижимости среднего размера
  # @return [Array] URL к изображениям недвижимости
  # @example
  #   Property.first.middle_pics_urls
  def middle_pics_urls
    res = []
    pictures.each do |picture|
      if picture.pic.middle.file&.exists?
        res << picture.pic.middle.url
      elsif picture.pic.file&.exists?
        res << picture.pic.url
      end
    end
    res
  end

  # URL к изображениям недвижимости маленького размера
  # @return [Array] URL к изображениям недвижимости
  # @example
  #   Property.first.mini_pics_urls
  def mini_pics_urls
    res = []
    pictures.each do |picture|
      if picture.pic.mini.file&.exists?
        res << picture.pic.mini.url
      elsif picture.pic.file&.exists?
        res << picture.pic.url
      end
    end
    res
  end

  def residential?
    property_supertype&.id == PropertySupertype::RESIDENTIAL
  end

  def commercial?
    property_supertype&.id == PropertySupertype::COMMERCIAL
  end

  def land?
    property_supertype&.id == PropertySupertype::LAND
  end

  # Обновляет счетчик активной недвижимости у локаций, в которых находится данная недвижимость
  # @example
  #   Property.first.update_counter_cache
  def update_counter_cache
    self.country&.update_active_properties_counter
    self.region&.update_active_properties_counter
    self.city&.update_active_properties_counter
    self.agency&.update_active_properties_counter


    self.country&.update_active_and_moderated_properties_counter
    self.region&.update_active_and_moderated_properties_counter
    self.city&.update_active_and_moderated_properties_counter
    self.agency&.update_active_and_moderated_properties_counter
  end

  def distance_to_city
    LocationDistance.distence_in_km(self, self.city)
  end

  def has_coordinates?
    latitude.present? && longitude.present?
  end

  def has_energy_efficiency?
    energy_efficiency_type.present?
  end

  def has_video_link?
    video_link.present?
  end
end

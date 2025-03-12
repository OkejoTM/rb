# == Schema Information
#
# Table name: countries
#
#  id                                    :bigint           not null, primary key
#  active_and_moderated_properties_count :integer          default(0), not null
#  active_properties_count               :integer          default(0), not null
#  coming_soon                           :boolean          default(TRUE)
#  continent                             :string(2)        default(""), indexed
#  created_by                            :integer
#  currencycode                          :string(3)        default("")
#  currencyname                          :string(20)       default("")
#  image                                 :string
#  is_active                             :boolean          default(FALSE)
#  is_popular                            :boolean          default(FALSE)
#  iso_alpha2                            :string(2)        default("")
#  languages                             :string(200)      default("")
#  latitude                              :float            default(0.0)
#  longitude                             :float            default(0.0)
#  name                                  :string(200)      default(""), indexed
#  properties_count                      :integer          indexed
#  show_agencies_on_website              :boolean          default(TRUE)
#  slug                                  :string           default(""), indexed
#  title_en                              :string(200)      default(""), indexed
#  title_genitive_en                     :string
#  title_genitive_ru                     :string
#  title_prepositional_en                :string
#  title_prepositional_ru                :string
#  title_ru                              :string(200)      default(""), indexed
#  updated_by                            :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  capital_id                            :integer
#

class Country < ApplicationRecord
  #@!group Режимы отображения
  # Африка
  AFRICA = "AF"
  # Австралия
  AUSTRALIA = "OC"
  # Европа
  EUROPE = "EU"
  # Азия
  ASIA = "AS"
  # Серверная Америка
  NORTH_AMERICA = "NA"
  # Южная Америка
  SOUTH_AMERICA = "SA"
  # Антарктида
  ANTARCTICA = "AN"
  #@!endgroup

  include SearchableRecord
  include Locationable
  include Articleable

  filter_params :has_not_locale,
                :has_active_and_moderated_property, :has_active_property, :has_property,
                :sort_location_by, :continent,
                :with_seo_template, :query

  has_many :regions, dependent: :destroy
  # has_many :cities, through: :regions
  # has_many :cities

  has_many :properties, dependent: :nullify

  has_and_belongs_to_many :agencies
  has_and_belongs_to_many :visible_agencies, -> { visible }, class_name: "Agency"

  has_many :seo_location_pages, as: :object, dependent: :destroy
  has_one :seo_agencies_page, as: :object, dependent: :destroy

  has_many :alternate_names, primary_key: 'id', foreign_key: 'geoname_id', dependent: :destroy
  belongs_to :capital, ->(country) { where(continent: country.continent) }, class_name: "City", foreign_key: 'capital_id'

  mount_uploader :image, PictureUploader

  accepts_nested_attributes_for :alternate_names, allow_destroy: true, reject_if: :all_blank

  # scope :active, -> { where(is_active: true).joins(:properties).where("properties.is_active = ?", true).distinct  }
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }

  scope :continent, -> (continent) {
    where(continent: continent) if continent != ""
  }

  scope :show_agencies_on_website, -> { where("agencies.show_agencies_on_website = true") }

  validates :iso_alpha2, uniqueness: true
  validates_with UniqFieldValidator, field: :slug, included_classes: [Country, ArticleCategory]

  # Все города для данной страны
  # @return [City] список городов
  # @example
  #   Country.first.country
  # @see City
  def cities
    City.where("cities.region_id in (?) AND cities.continent = ?", regions.ids, continent)
  end

  # URL к стране
  # @param property_supertype [PropertySupertype] категория недвижимости
  # @return [String] URL к стране
  def seo_path(property_supertype = nil)
    result = "/#{I18n.locale}/#{slug}"
    "#{result}/#{property_supertype.slug}" if property_supertype.present?
    result
  end
end

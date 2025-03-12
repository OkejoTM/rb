# == Schema Information
#
# Table name: cities
#
#  id                                    :bigint           not null, primary key
#  active_and_moderated_properties_count :integer          default(0), not null
#  active_properties_count               :integer          default(0), not null
#  admin1                                :string(20)       default("")
#  admin2                                :string(80)       default("")
#  admin3                                :string(20)       default("")
#  admin4                                :string(20)       default("")
#  coming_soon                           :boolean          default(TRUE)
#  continent                             :string(20)       indexed
#  created_by                            :integer
#  fcode                                 :string(10)       default("")
#  image                                 :string
#  is_active                             :boolean          default(FALSE)
#  is_popular                            :boolean          default(FALSE)
#  latitude                              :float            default(0.0)
#  longitude                             :float            default(0.0)
#  name                                  :string(200)      default(""), indexed
#  properties_count                      :integer          indexed
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
#  region_id                             :bigint           indexed
#

class City < ApplicationRecord

  include SearchableRecord
  include Locationable

  filter_params :continent, :country_id, :region_id, :has_not_locale,
                :has_active_and_moderated_property, :has_active_property, :has_property,
                :sort_location_by, :with_seo_template, :query

  belongs_to :region, optional: true, counter_cache: true
  # has_one :country, through: :region

  has_many :properties, dependent: :nullify

  has_and_belongs_to_many :agencies
  has_and_belongs_to_many :visible_agencies, -> { visible }, class_name: "Agency"

  has_many :seo_location_pages, as: :object, dependent: :destroy
  has_one :seo_agencies_page, as: :object, dependent: :destroy

  has_many :alternate_names, primary_key: 'id', foreign_key: 'geoname_id', dependent: :destroy

  mount_uploader :image, PictureUploader

  accepts_nested_attributes_for :alternate_names, allow_destroy: true, reject_if: :all_blank

  scope :administrative_center, -> { where(fcode: 'PPLA') }
  scope :capitals, -> { where(fcode: 'PPLC') }

  # scope :active, -> { joins(:region).joins("INNER JOIN countries ON countries.id = regions.country_id").joins(:properties)
  #                            .where("cities.is_active = ? AND regions.is_active = ? AND countries.is_active = ? AND properties.is_active = ?", true, true, true, true).distinct }
  scope :active, -> { joins(:region).joins("INNER JOIN countries ON countries.id = regions.country_id")
                          .where("cities.is_active = ? AND regions.is_active = ? AND countries.is_active = ?", true, true, true).distinct }
  scope :inactive, -> { joins(:region).joins("INNER JOIN countries ON countries.id = regions.country_id")
                               .where("cities.is_active = ? OR regions.is_active = ? OR countries.is_active = ?", false, false, false) }

  scope :has_active_and_moderated_property, -> { where("cities.active_and_moderated_properties_count > 0") }
  scope :has_active_property, -> { where("cities.active_properties_count > 0") }
  scope :has_property, -> { where("cities.properties_count > 0") }

  scope :country_id, -> (id) {
    where(region_id: Country.find(id).region_ids) if id.to_i > 0
  }

  scope :region_id, -> (id) {
    where(region_id: id) if id.to_i > 0
  }

  scope :continent, -> (continent) {
    if continent == "AS"
      where(continent: [continent, "china_and_india"])
    else
      where(continent: continent)
    end
  }

  # URL к городу
  # @return [String] URL к городу
  # @example
  #   City.first.seo_path
  def seo_path
    if region.present? && region.country.present?
      return "#{region.country.seo_path}/c/#{slug}"
    end
    "/#{I18n.locale}/c/#{slug}"
  end

  # Сделать город административным центром
  # @example
  #   City.first.become_administative_center
  # @see http://download.geonames.org/export/dump/featureCodes_en.txt
  def become_administative_center
    self.update_column(:fcode, 'PPLA')
  end

  # Страна, в которой находится город
  # @return [Country] страна
  # @example
  #   City.first.country
  # @see Country
  def country
    self.region.country
  end

  # Сделать город обычного типа
  # @example
  #   City.first.become_simple_city
  # @see http://download.geonames.org/export/dump/featureCodes_en.txt
  def become_simple_city
    self.update_column(:fcode, 'PPL')
  end

  # Сделать город столицей
  # @example
  #   City.first.become_capital
  # @see http://download.geonames.org/export/dump/featureCodes_en.txt
  def become_capital
    self.update_column(:fcode, 'PPLC')
  end

  # Дистанция до города
  # @example
  #   City.first.find_far_distance
  def find_far_distance
    neighbour_cities = self.region.cities.where("cities.longitude != 0 AND cities.latitude != 0")
    min = MAX_DISTANCE_IN_KM
    neighbour_cities.each do |city|
      distance = LocationDistance.distence_in_km(self, city)
      min = distance if distance > 0 && distance < min
    end
    min
  end

end

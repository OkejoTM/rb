# == Schema Information
#
# Table name: regions
#
#  id                                    :bigint           not null, primary key
#  active_and_moderated_properties_count :integer          default(0), not null
#  active_properties_count               :integer          default(0), not null
#  cities_count                          :integer          default(0)
#  coming_soon                           :boolean          default(TRUE)
#  created_by                            :integer
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
#  country_id                            :bigint           indexed
#

class Region < ApplicationRecord

  include SearchableRecord
  include Locationable
  include ScopeModule

  filter_params :country_id, :has_not_locale,
                :has_active_and_moderated_property, :has_active_property, :has_property,
                :sort_location_by,
                :continent, :with_seo_template, :query

  belongs_to :country
  has_many :cities, -> (region) { where(continent: region.country.continent) }, dependent: :destroy

  has_many :properties, dependent: :nullify

  has_and_belongs_to_many :agencies
  has_and_belongs_to_many :visible_agencies, -> { visible }, class_name: "Agency"

  has_many :seo_location_pages, as: :object, dependent: :destroy
  has_one :seo_agencies_page, as: :object, dependent: :destroy

  has_many :alternate_names, primary_key: 'id', foreign_key: 'geoname_id', dependent: :destroy

  mount_uploader :image, PictureUploader

  accepts_nested_attributes_for :alternate_names, allow_destroy: true, reject_if: :all_blank

  scopes_with_value :country_id

  # scope :active, -> { joins(:country).joins(:properties).where("regions.is_active = ? AND countries.is_active = ? AND properties.is_active = ?", true, true, true).distinct }
  scope :active, -> { joins(:country).where("regions.is_active = ? AND countries.is_active = ?", true, true).distinct }
  scope :inactive, -> { joins(:country).where("regions.is_active = ? OR countries.is_active = ?", false, false) }

  scope :has_active_and_moderated_property, -> { where("regions.active_and_moderated_properties_count > 0") }
  scope :has_active_property, -> { where("regions.active_properties_count > 0") }
  scope :has_property, -> { where("regions.properties_count > 0") }

  scope :continent, -> (continent) {
    joins(:country).where(countries: { continent: continent })
  }

  # URL к области
  # @return [String] URL к области
  # @example
  #   Region.first.seo_path
  def seo_path
    if country.present?
      return "#{country.seo_path}/r/#{slug}"
    end
    "/#{I18n.locale}/r/#{slug}"
  end

  # Административный цента для региона
  # @return [City] административный цента для региона
  # @example
  #   Region.first.region_center
  # @see City
  def region_center
    City.where(region_id: id).where(continent: country.continent).administrative_center.first
  end
end

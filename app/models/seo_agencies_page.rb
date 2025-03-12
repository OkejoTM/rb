# == Schema Information
#
# Table name: seo_agencies_pages
#
#  id                  :bigint           not null, primary key
#  agencies_count      :integer          default(0)
#  created_by          :integer
#  description_en      :text             default("")
#  description_ru      :text             default("")
#  h1_en               :string
#  h1_ru               :string
#  is_active           :boolean          default(TRUE)
#  meta_description_en :text             default("")
#  meta_description_ru :text             default("")
#  object_type         :string           indexed => [object_id], indexed => [object_id, default_page_id]
#  title_en            :string
#  title_ru            :string
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  default_page_id     :integer          indexed, indexed => [object_id, object_type]
#  object_id           :integer          indexed => [object_type], indexed => [default_page_id, object_type]
#

# Класс для SEO-страниц списка агентств
class SeoAgenciesPage < ApplicationRecord
  include BasicPage

  belongs_to :object, polymorphic: true #as :area

  belongs_to :default_page, class_name: 'SeoAgenciesPage'

  validates :default_page_id, uniqueness: { scope: [:object_id, :object_type] }

  after_save :update_agencies_count

  scope :active, -> { where("is_active = true AND agencies_count > 0") }
  scope :for_countries, -> { where("object_type = 'Country'") }
  scope :for_regions, -> (country) {
    if country.present?
      where("object_type = 'Region' AND object_id IN (?)", country.region_ids)
    else
      where("object_type = 'Region'")
    end
  }
  scope :for_cities, -> (region) {
    if region.present?
      where("object_type = 'City' AND object_id IN (?)", region.city_ids)
    else
      where("object_type = 'City'")
    end
  }


  class << self
    def default_page
      SeoAgenciesPage.find_by(default_page: nil)
    end
  end

  # Активна ли страница
  # @return [Boolean]
  def active?
    is_active? && agencies_count > 0
  end

  # URL страницы
  # @return [String]
  def seo_path
    seo_url = "#{UrlsHelper.frontend_agencies_path}"

    if country.present?
      UrlsHelper.frontend_country_agencies_path(country.slug)
    elsif region.present?
      UrlsHelper.frontend_region_agencies_path(region.country.slug, region.slug)
    elsif city.present?
      UrlsHelper.frontend_city_agencies_path(city.country.slug, city.slug)
    else
      seo_url
    end
  end

  def country
    object if object_type == 'Country'
  end

  def region
    object if object_type == 'Region'
  end

  def city
    object if object_type == 'City'
  end

  # Агентства для сео-страницы
  # @return [Array]
  def agencies
    result =
      if country.present?
        Agency.eager_load(:active_countries).where(countries: { slug: country.slug })
      elsif region.present?
        Agency.eager_load(:regions).where(regions: { slug: region.slug })
      elsif city.present?
        Agency.eager_load(:cities).where(cities: { slug: city.slug })
      else
        Agency.all
      end

    result.visible.order(:name_ru)
  end

  # Callback для обновления количества агентств для сео страницы
  def update_agencies_count
    self.update_column(:agencies_count, agencies.visible.count)
  end
end

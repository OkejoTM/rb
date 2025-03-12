# == Schema Information
#
# Table name: seo_location_pages
#
#  id                  :bigint           not null, primary key
#  created_by          :integer
#  description_en      :text             default("")
#  description_ru      :text             default("")
#  h1_en               :string
#  h1_ru               :string
#  is_active           :boolean          default(TRUE)
#  meta_description_en :text             default("")
#  meta_description_ru :text             default("")
#  object_type         :string           indexed => [object_id], indexed => [object_id, default_page_id]
#  properties_count    :integer          default(0)
#  title_en            :string
#  title_ru            :string
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  default_page_id     :integer          indexed, indexed => [object_id, object_type]
#  object_id           :integer          indexed => [object_type], indexed => [default_page_id, object_type]
#

# Класс для SEO-страниц стран, регионов, населённых пунктов
class SeoLocationPage < ApplicationRecord
  include BasicPage

  belongs_to :object, polymorphic: true #as :area
  belongs_to :default_page, class_name: 'SeoTemplatePage'

  has_one :seo_template, through: :default_page

  scope :country, -> { where(object_type: 'Country') }
  scope :region, -> { where(object_type: 'Region') }
  scope :city, -> { where(object_type: 'City') }

  validates :default_page_id, uniqueness: { scope: [:object_id, :object_type] }

  after_save :update_properties_count

  delegate :link_name, to: :default_page

  # Активна ли страница
  # @return [Boolean]
  def active?
    is_active? && properties_count > 0
  end

  # "Первичность" страницы. Например, страница /ru/spain/r/valenciana - первична, а /ru/spain/r/valenciana/f/cheap - нет
  # @return [Boolean]
  def primary?
    seo_template.is_main?
  end

  # URL страницы
  # @return [String]
  def seo_path
    # TODO должен учитывать локацию
    seo_url =
        if seo_template.is_main?
          seo_path_for_main_template
        else
          seo_path_for_template
        end

    seo_url = "#{seo_url}/f/#{seo_template.slug}" if seo_template.slug.present?
    seo_url
  end

  # Недвижимость для сео-страницы
  # @return [Array]
  def properties
    SearchProperties.new(self.to_params).perform
  end

  # Генерирует хэш на основе заполненных полей фильтра
  # исключая незаданные поля и поля, значение которых равно 0
  # @return [Hash]
  def to_params
    page_params = {}
    if object.present?
      case object_type
        when "Country"
          page_params[:country_id] = object.id
        when "Region"
          page_params[:country_id] = object.country.id
          page_params[:region_id] = object.id
        when "City"
          page_params[:country_id] = object.country.id
          page_params[:city_id] = object.id
      end
    else
      case seo_template.property_supertype&.id
        when PropertySupertype::COMMERCIAL
          page_params[:commercial] = 'on'
        when PropertySupertype::RESIDENTIAL
          page_params[:residential] = 'on'
        when PropertySupertype::LAND
          page_params[:land] = 'on'
      end
    end

    page_params["#{object_type.downcase}_id"] = object_id

    page_params['by_tags'] = seo_template.property_tag_ids if seo_template.property_tags.present?

    params_hash = seo_template
                      .params_for_filter
                      .merge(page_params)
                      .select { |_, v| v.present? && v != '0' }
    ActionController::Parameters.new(params_hash)
  end

  # Callback для обновления количества недвижимости для сео страницы
  def update_properties_count
    self.update_column(:properties_count, properties.count)
  end

  private
    # URL для основного сео шаблона
    def seo_path_for_main_template
      if seo_template.template_location_type == SeoTemplate::TYPE_WORLD
        if object.present?
          "#{object.seo_path}/#{PropertySupertype::slug_by_id(seo_template.property_supertype.id)}"
        else
          seo_template.property_supertype.seo_path
        end
      else
        seo_path_for_template
      end
    end

    # URL для сео шаблона
    def seo_path_for_template
      if object.present?
        object.seo_path
      else
        "/#{I18n.locale}/#{PropertySupertype::slug_by_id(seo_template.property_supertype_id)}"
      end
    end
end

# == Schema Information
#
# Table name: seo_template_pages
#
#  id                  :bigint           not null, primary key
#  h1_ru               :string
#  h1_en               :string
#  title_ru            :string
#  title_en            :string
#  description_ru      :text             default("")
#  description_en      :text             default("")
#  meta_description_ru :text             default("")
#  meta_description_en :text             default("")
#  seo_template_id     :integer
#  created_by          :integer
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# Класс для хранения текстовых настроек SEO-шаблона
class SeoTemplatePage < ApplicationRecord
  include BasicPage
  # include PageFieldsModule
  include PageSnippetsModule

  belongs_to :seo_template
  belongs_to :object, polymorphic: true #as :area

  has_many :seo_location_pages, foreign_key: :default_page_id, dependent: :destroy

  validates :seo_template_id, uniqueness: true

  # Название ссылки на страницу
  # @return [String]
  delegate :link_name, to: :seo_template

  # "Первичность" страницы. Например, страница /ru/spain/r/valenciana - первична, а /ru/spain/r/valenciana/f/cheap - нет
  # @return [Boolean]
  def primary?
    seo_template.is_main?
  end

  # Генерирует хэш на основе заполненных полей фильтра
  # исключая незаданные поля и поля, значение которых равно 0
  # @return [Hash]
  def to_params
    page_params = {}
    case seo_template.property_supertype&.id
      when PropertySupertype::COMMERCIAL
        page_params[:commercial] = 'on'
      when PropertySupertype::RESIDENTIAL
        page_params[:residential] = 'on'
      when PropertySupertype::LAND
        page_params[:land] = 'on'
    end

    page_params['by_tags'] = seo_template.property_tag_ids if seo_template.property_tags.present?

    params_hash = seo_template
                      .params_for_filter
                      .merge(page_params)
                      .select { |_, v| v.present? && v != '0' }
    ActionController::Parameters.new(params_hash)
  end

  private
    # Callback для создания страницы с дефолтными полями, если таковой не существует
    def create_default_page
      self.default_page = ::SeoPage.find_or_create_by!(property_supertype_id: property_supertype_id,
                                                       seo_template_id: seo_template_id,
                                                       object_type: area.class.to_s,
                                                       object_id: nil)
    end
end

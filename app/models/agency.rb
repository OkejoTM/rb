# == Schema Information
#
# Table name: agencies
#
#  id                                    :bigint           not null, primary key
#  about_en                              :string           default("")
#  about_ru                              :string           default("")
#  active_and_moderated_properties_count :integer          default(0), not null
#  active_properties_count               :integer          default(0), not null
#  autotranslated_about_de               :boolean          default(FALSE)
#  autotranslated_about_en               :boolean          default(FALSE)
#  created_by                            :integer
#  has_contract                          :boolean          default(FALSE)
#  hs_link                               :string
#  hs_properties_links                   :text
#  is_active                             :boolean          default(FALSE)
#  name_en                               :string
#  name_ru                               :string
#  org_name_en                           :string
#  org_name_ru                           :string
#  parse_source                          :string(100)
#  prian_link                            :string
#  prian_properties_links                :text
#  properties_count                      :integer          default(0), not null, indexed
#  show_on_website                       :boolean          default(TRUE)
#  slug                                  :string           indexed
#  updated_by                            :integer
#  website                               :string
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#

class Agency < ApplicationRecord
  include Localizable
  include UserstampModule
  include ActivePropertiesCounter
  include Filterable
  include QueryModule
  include Decoratable
  include Translatable

  translate_fields :name, :about, :meta_description
  query_fields :name_ru, :name_en

  serialize :prian_properties_links, Array
  serialize :hs_properties_links, Array

  filter_params :query

  has_one :logo, as: :imageable, class_name: "Picture", dependent: :destroy
  # has_many :agency_offices

  has_many :properties, dependent: :destroy

  has_many :contact_people, dependent: :destroy, index_errors: true
  has_many :contacts, as: :contactable, dependent: :destroy, index_errors: true
  has_many :agency_other_contacts, dependent: :destroy
  has_many :messengers, dependent: :destroy, index_errors: true
  has_many :real_estate_parsers, dependent: :destroy, index_errors: true
  has_and_belongs_to_many :agency_types, optional: true

  has_one :seo_agency_page, dependent: :destroy

  has_and_belongs_to_many :countries, optional: true
  has_and_belongs_to_many :active_countries,
                          -> { where('agencies_countries.is_active = true') },
                          class_name: 'Country'
  has_and_belongs_to_many :regions, optional: true
  has_and_belongs_to_many :cities, optional: true

  accepts_nested_attributes_for :logo, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contact_people, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: proc { |attributes| attributes['value'].blank? }
  accepts_nested_attributes_for :agency_other_contacts, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :messengers, allow_destroy: true, reject_if: proc { |attributes| attributes['phone'].blank? }
  accepts_nested_attributes_for :seo_agency_page, allow_destroy: true, reject_if: :all_blank

  scope :active, -> { where("agencies.is_active = true") }
  scope :inactive, -> { where("agencies.is_active = false") }

  scope :show_on_website, -> { where("agencies.show_on_website = true") }

  scope :visible, -> { active.has_active_and_moderated_property.show_on_website }

  scope :without_translation, -> {
    where("name_ru = '' OR name_ru IS NULL OR
           name_en = '' OR name_en IS NULL")
  }

  scope :has_contract, -> { where(has_contract: true).where.not(parse_source: nil) }

  validates :slug, slug: true
  validates :name_ru, :name_en, :slug, presence: true
  validates_associated :contact_people, :contacts, :messengers

  class << self
    def new_with_dependencies
      Agency.new(seo_agency_page: SeoAgencyPage.new_default_agency_page)
    end
  end

  # Приоритетная страна для данного агентства, в которой больше всего объектов
  # @return [String] id страны
  # @example
  #   Agency.first.priority_country
  def priority_country
    self.properties.select(:country_id, "COUNT(*) as count").group(:country_id).order("count DESC").first&.country
  end

  # URL к агентству
  # @return [String] URL к агентству
  def seo_path
    "#{UrlsHelper.frontend_agencies_path}/#{self.slug}"
  end
end

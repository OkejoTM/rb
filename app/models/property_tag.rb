# == Schema Information
#
# Table name: property_tags
#
#  id                       :bigint           not null, primary key
#  is_active                :boolean          default(TRUE)
#  moderated                :boolean          default(FALSE), not null
#  position                 :integer
#  show_in_filter           :boolean          default(FALSE), not null
#  title_en                 :string
#  title_ru                 :string
#  property_tag_category_id :bigint           indexed
#

# Тег для недвижимости
class PropertyTag < ApplicationRecord
  include Titleable
  include Moderatable

  has_and_belongs_to_many :properties
  has_and_belongs_to_many :seo_templates

  belongs_to :property_tag_category
  has_one :property_supertype, through: :property_tag_category

  has_many :property_tag_aliases, dependent: :destroy

  scope :common, -> { joins(:property_tag_category)
                          .where(property_tag_categories: { property_supertype_id: nil }) }

  scope :visible, -> { where(show_in_filter: true) }

  scope :by_property_supertype,
        -> (property_supertype_id) { joins(:property_tag_category)
                                         .where(property_tag_categories: { property_supertype_id: property_supertype_id }) }

  accepts_nested_attributes_for :property_tag_aliases, allow_destroy: true

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тег недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тег недвижимости уже существует!' }
  validates :property_tag_category_id, presence: { message: 'Категория тегов должна быть указана' }

  def aliases_list
    property_tag_aliases.map(&:name)
  end
end

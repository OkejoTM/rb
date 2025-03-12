# == Schema Information
#
# Table name: property_tag_categories
#
#  id                    :bigint           not null, primary key
#  title_en              :string
#  title_ru              :string
#  property_supertype_id :bigint           indexed
#

# Несколько тегов недвижимости, сгруппированные под одним общим заголовком
class PropertyTagCategory < ApplicationRecord
  include Titleable

  #@!group Категории тегов (соответствует id записи в БД)
  COMMON_GROUP = 1
  COMMERCIAL_GROUP = 2
  RESIDENTIAL_GROUP = 3
  HOUSE_GROUP = 4
  LAND_GROUP = 5
  #@!endgroup

  belongs_to :property_supertype
  has_many :property_tags, dependent: :nullify
  has_many :properties, through: :property_tags

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория тегов недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория тегов недвижимости уже существует!' }
end

# == Schema Information
#
# Table name: property_type_groups
#
#  id                    :bigint           not null, primary key
#  title_en              :string
#  title_ru              :string
#  property_supertype_id :bigint           indexed
#

# Несколько типов недвижимости, сгруппированные под одним общим заголовком
class PropertyTypeGroup < ApplicationRecord
  include Titleable

  # has_many :properties, dependent: :nullify

  belongs_to :property_supertype
  has_many :property_types, dependent: :nullify
  has_many :properties, through: :property_types

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
  validates :property_supertype_id, presence: { message: 'Категория объектов должна быть указана' }
end

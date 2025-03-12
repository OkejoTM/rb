# == Schema Information
#
# Table name: location_types
#
#  id       :bigint           not null, primary key
#  title_ru :string
#  title_en :string
#

class LocationType < ApplicationRecord
  include Titleable

  has_and_belongs_to_many :properties

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип расположения уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип расположения уже существует!' }
end

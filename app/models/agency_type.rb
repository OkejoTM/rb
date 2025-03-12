# == Schema Information
#
# Table name: agency_types
#
#  id       :bigint           not null, primary key
#  title_ru :string
#  title_en :string
#

class AgencyType < ApplicationRecord
  include Titleable

  has_and_belongs_to_many :agencies

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип агентства уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип агентства уже существует!' }
end

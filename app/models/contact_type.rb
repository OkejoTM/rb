# == Schema Information
#
# Table name: contact_types
#
#  id         :bigint           not null, primary key
#  title_ru   :string
#  title_en   :string
#  icon_class :string           default(""), not null
#

class ContactType < ApplicationRecord
  include Titleable

  has_many :contacts, dependent: :nullify

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип контакта агентства уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип контакта агентства уже существует!' }
end

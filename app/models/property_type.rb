# == Schema Information
#
# Table name: property_types
#
#  id                     :bigint           not null, primary key
#  title_en               :string
#  title_ru               :string
#  property_supertype_id  :bigint           indexed
#  property_type_group_id :bigint           indexed
#

# Один тип недвижимости, никаких логических И
class PropertyType < ApplicationRecord
  #@!group Типы недвижимости. Число соответствует id в БД
  # @TODO доделать, когда будут готовы все типы недвижимости
  # Апартаменты
  APARTMENT = 3
  # Квартира
  FLAT = 20
  # Пентхаус
  PENTHOUSE = 21
  # Дом
  HOUSE = 1
  # Шале
  CHALET = 22
  # Вилла
  VILLA = 23
  # Бунгало
  BUNGALOW = 19
  # Таунхаус
  TOWNHOUSE = 8
  # Элитная недвижимость
  ELITE = 5
  # Замок
  CASTLE = 24
  # Другое
  OTHER = 15
  #@!endgroup

  include Titleable

  has_many :properties, dependent: :nullify

  belongs_to :property_supertype
  belongs_to :property_type_group

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
  validates :property_supertype_id, presence: { message: 'Категория объектов должна быть указана' }

  def name_by_id
    case self.id
      when PropertyType::APARTMENT
        "apartment"
      when PropertyType::FLAT
        "flat"
      when PropertyType::PENTHOUSE
        "penthouse"
      when PropertyType::HOUSE
        "house"
      when PropertyType::CHALET
        "chalet"
      when PropertyType::VILLA
        "villa"
      when PropertyType::BUNGALOW
        "bungalow"
      when PropertyType::TOWNHOUSE
        "townhouse"
      when PropertyType::ELITE
        "elite"
      when PropertyType::CASTLE
        "castle"
      when PropertyType::OTHER
        "other"
      else
        ''
    end
  end
end

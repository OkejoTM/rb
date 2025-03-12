# == Schema Information
#
# Table name: property_supertypes
#
#  id       :bigint           not null, primary key
#  title_ru :string
#  title_en :string
#

class PropertySupertype < ApplicationRecord
  include Titleable

  #@!group Категории недвижимости (соответствует id записи в БД)
  # Коммерческая недвижимость
  COMMERCIAL = 1
  # Жилая недвижимость
  RESIDENTIAL = 2
  # Земельные участки
  LAND = 3
  #@!endgroup

  SLUGS = {
      PropertySupertype::COMMERCIAL => 'commercial',
      PropertySupertype::RESIDENTIAL => 'residential',
      PropertySupertype::LAND => 'land'
  }

  has_many :property_types, dependent: :nullify
  has_many :property_type_groups, dependent: :nullify
  has_many :properties, through: :property_types

  scope :commercial, -> { find(PropertySupertype::COMMERCIAL) }
  scope :residential, -> { find(PropertySupertype::RESIDENTIAL) }
  scope :land, -> { find(PropertySupertype::LAND) }

  scope :by_slug, -> (slug) { find(PropertySupertype::SLUGS.invert[slug]) }

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория недвижимости уже существует!' }

  class << self
    # Возвращает slug для ссылки в по id категории недвижимости
    # @return [String]
    def slug_by_id(id)
      PropertySupertype::SLUGS[id]
    end
  end

  # Возвращает slug для ссылки в по id категории недвижимости
  # @return [String]
  def slug
    PropertySupertype::slug_by_id(id)
  end

  # URL к категории недвижимости
  # @param country [Country] страна
  # @return [String] URL к категории недвижимости
  def seo_path(country = nil)
    return "/#{I18n.locale}/#{country.slug}/#{slug}" if country.present?
    "/#{I18n.locale}/#{slug}"
  end
end

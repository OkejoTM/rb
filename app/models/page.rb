# == Schema Information
#
# Table name: pages
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
#  created_by          :integer
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  slug                :string
#

class Page < ApplicationRecord
  #@!group Категории недвижимости (соответствует id записи в БД)
  # Правилами обработки персональных данных
  TERMS = 1
  # Политика конфиденциальности
  PRIVACY = 2
  #@!endgroup

  include BasicPage

  validates :h1_ru, :h1_en, :title_ru, :title_en, :slug, uniqueness: true, presence: true

  scope :terms, -> { find(TERMS) }
  scope :privacy, -> { find(PRIVACY) }

  def seo_path
    "/#{I18n.locale}/#{slug}"
  end
end

# == Schema Information
#
# Table name: seo_templates_groups
#
#  id        :bigint           not null, primary key
#  title_ru  :string
#  title_en  :string
#  is_active :boolean
#

# Несколько сео шаблонов, сгруппированные под одним общим заголовком
class SeoTemplatesGroup < ApplicationRecord
  include Titleable

  has_many :seo_templates, dependent: :nullify

  scope :active, -> { joins(:seo_templates).where("is_active = ? AND COUNT(seo_templates) > 0", true) }

  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такой тип недвижимости уже существует!' }
end

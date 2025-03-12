# == Schema Information
#
# Table name: seo_agency_pages
#
#  id                  :bigint           not null, primary key
#  created_by          :integer
#  description_en      :text             default("")
#  description_ru      :text             default("")
#  h1_en               :string
#  h1_ru               :string
#  is_active           :boolean          default(TRUE)
#  meta_description_en :text             default("")
#  meta_description_ru :text             default("")
#  title_en            :string
#  title_ru            :string
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agency_id           :integer          indexed
#  default_page_id     :integer          indexed
#

# Класс для SEO-страниц агентств
class SeoAgencyPage < ApplicationRecord
  include BasicPage

  belongs_to :agency

  belongs_to :default_page, class_name: 'SeoAgencyPage'

  validates :default_page_id, uniqueness: { scope: [:agency_id] }

  scope :active, -> { where(is_active: true) }

  class << self
    def default_page
      SeoAgencyPage.find_by(default_page: nil)
    end

    def new_default_agency_page(**args)
      SeoAgencyPage.new(args.merge(default_page_id: default_page.id))
    end
  end

  # Активна ли страница
  # @return [Boolean]
  def active?
    is_active?
  end

  # URL страницы
  # @return [String]
  delegate :seo_path, to: :agency
end

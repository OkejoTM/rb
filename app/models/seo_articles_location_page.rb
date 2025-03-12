# == Schema Information
#
# Table name: seo_articles_pages
#
#  id                  :bigint           not null, primary key
#  created_by          :integer
#  description_en      :text             default("")
#  description_ru      :text             default("")
#  h1_en               :string
#  h1_ru               :string
#  meta_description_en :text             default("")
#  meta_description_ru :text             default("")
#  title_en            :string
#  title_ru            :string
#  type                :string
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  article_category_id :bigint           indexed
#  default_page_id     :integer
#

# Класс для SEO-страниц списка статей (главная для страны)
class SeoArticlesLocationPage < SeoArticlesPage
  belongs_to :default_page, class_name: 'SeoArticlesLocationPage'

  class << self
    def primary
      SeoArticlesLocationPage.find_by(default_page: nil)
    end
  end
end

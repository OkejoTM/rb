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

# Класс для SEO-страниц списка статей в категории
class SeoArticlesCategoryPage < SeoArticlesPage
  belongs_to :default_page, class_name: 'SeoArticlesCategoryPage'

  belongs_to :article_category

  validates :default_page_id, presence: true, if: :new_record?

  class << self
    def primary
      SeoArticlesCategoryPage.find_by(default_page: nil)
    end
  end

  # Активна ли страница
  # @return [Boolean]
  def active?
    # Страница активна, если это страница категории статей и на странице есть статьи
    article_category.present? && article_category.active?
  end
end

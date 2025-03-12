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

# Класс для SEO-страниц списка статей (главная список всех статей)
class SeoArticlesIndexPage < SeoArticlesPage
  class << self
    def primary
      SeoArticlesIndexPage.first
    end
  end

  # Активна ли страница
  # @return [Boolean]
  def active?
    Articles.count > 0
  end

  # URL страницы
  # @return [String]
  def seo_path
    UrlsHelper.frontend_articles_path
  end

  # Статьи для сео-страницы
  # @return [Array]
  def articles
    Articles.active.order(created_at: :desc)
  end
end

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

# Класс для SEO-страниц списка статей
class SeoArticlesPage < ApplicationRecord
  include BasicPage

  # after_save :update_articles_count

  # scope :active, -> { where("is_active = true AND articles_count > 0") }

  validates :h1_ru, :h1_en, :title_ru, :title_en, uniqueness: true, presence: true

  class << self
    def new_default_articles_categories_page(**args)
      SeoArticlesCategoryPage.new(args.merge(default_page_id: SeoArticlesCategoryPage.primary.id))
    end

    def new_default_countries_page(**args)
      SeoArticlesLocationPage.new(args.merge(default_page_id: SeoArticlesLocationPage.primary.id))
    end
  end

  # Активна ли страница
  # @return [Boolean]
  # def active?
  #   # Страница активна, если это страница категории статей и на странице есть статьи
  #   article_category.present? && article_category.active? if page_type == PAGE_TYPE_CATEGORY
  #   true # Иначе страница всегда активна
  # end

  # URL страницы
  # @return [String]
  # def seo_path
  #   if country.present? && article_category.present?
  #     UrlsHelper.frontend_article_category_and_country_articles_path(country.slug, article_category.slug)
  #   elsif article_category.present?
  #     UrlsHelper.frontend_article_category_articles_path(article_category.slug)
  #   elsif country.present?
  #     UrlsHelper.frontend_region_agencies_path(country.slug)
  #   else
  #     UrlsHelper.frontend_articles_path
  #   end
  # end

  # Статьи для сео-страницы
  # @return [Array]
  # def articles
  # result =
  #   if country.present?
  #     Article.eager_load(:countries).where('countries.slug = ?', country.slug)
  #   elsif region.present?
  #     Agency.eager_load(:regions).where('regions.slug = ?', region.slug)
  #   elsif city.present?
  #     Agency.eager_load(:cities).where('cities.slug = ?', city.slug)
  #   else
  #     Agency.all
  #   end
  #
  # result.visible.order(:name_ru)
  # end

  # # Callback для обновления количества статей для сео страницы
  # def update_articles_count
  #   self.update_column(:articles_count, articles.active.count)
  # end
end

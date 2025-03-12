# == Schema Information
#
# Table name: article_categories
#
#  id       :bigint           not null, primary key
#  title_ru :string
#  title_en :string
#  slug     :string
#

class ArticleCategory < ApplicationRecord
  include Titleable
  include Articleable

  has_many :countries, through: :articles

  has_one :seo_articles_page, dependent: :destroy
  accepts_nested_attributes_for :seo_articles_page, allow_destroy: true

  scope :active, -> { joins(:articles).distinct }

  validates_with UniqFieldValidator, field: :slug, included_classes: [Country, ArticleCategory]
  validates :title_ru, presence: { message: 'Заголовок на русском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория статей уже существует!' }
  validates :title_en, presence: { message: 'Заголовок на английском языке должен быть указан!' },
            uniqueness: { message: 'Такая категория статей уже существует!' }
  validates :seo_articles_page, presence: true
  validates_associated :seo_articles_page
  validates :slug, uniqueness: true, slug: true

  class << self
    def new_with_dependencies
      ArticleCategory.new(seo_articles_page: SeoArticlesPage.new_default_articles_categories_page)
    end
  end

  def seo_path
    "#{UrlsHelper.frontend_articles_path}/#{slug}"
  end

  def active?
    articles.present?
  end
end

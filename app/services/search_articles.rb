# module Services
class SearchArticles

  def initialize(country:, article_category:, locale: I18n.locale)
    @country = country
    @article_category = article_category
    @locale = locale
  end

  # TODO: дописать комментарий
  #Осуществляет поиск
  def perform
    articles =
      if @country.present? && @article_category.present?
        Article.where(country_id: @country.id, article_category_id: @article_category.id)
      elsif @country.present?
        Article.where(country_id: @country.id)
      elsif @article_category.present?
        Article.where(article_category_id: @article_category.id)
      else
        Article.all
      end

    articles.visible(@locale).order(created_at: :desc)
  end
end
# end

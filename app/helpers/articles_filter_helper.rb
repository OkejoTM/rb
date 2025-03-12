module ArticlesFilterHelper
  # Опции для селекта страны для фильтрации статей
  # @return [Array<Array<String, Integer>>]
  def articles_countries_options
    [[I18n.t(:any_feminine, scope: :common), 0]].concat(Article.all.map(&:country).uniq.pluck(:title_ru, :slug))
  end

  # Slug выбранной страны на странице списка статей
  # @param [ActionController::Parameters] params параметры фильтрации статей
  # @return [String]
  def selected_country_url(params)
    if params[:country_url].present? && params[:country_url] != '0'
      params[:country_url]
    elsif Country.exists?(slug: params[:country_or_category_url])
      params[:country_or_category_url]
    end
  end

  # Slug выбранной категории статей на странице списка статей
  # @param [ActionController::Parameters] params параметры фильтрации статей
  # @return [String]
  def selected_article_category_url(params)
    if params[:article_category_url].present?
      params[:article_category_url]
    elsif ArticleCategory.exists?(slug: params[:country_or_category_url])
      params[:country_or_category_url]
    end
  end

  # Проверяет, доступен ли выбор категории статей для заданных параметров фильтрации статей
  # @param [ActionController::Parameters] params параметры фильтрации статей
  # @return [Boolean]
  def article_categories_available?(params)
    selected_country_url(params).blank?
  end

  # Проверяет, доступна ли заданная категория статей для заданных параметров фильтрации статей
  # @param [ArticleCategory] article_category категория статей
  # @param [ActionController::Parameters] params параметры фильтрации статей
  # @return [Boolean]
  def article_category_available?(article_category, params)
    country_url = selected_country_url(params)
    # если не выбрана ни одна страна или страна выбрана и у этой страны есть хотя бы одна статья в этой категории
    (country_url.blank? || article_category.countries.map(&:slug).include?(country_url)) &&
        article_category.has_visible_articles?(I18n.locale)
  end

  # Проверяет, выбрана ли заданная категория статей для заданных параметров фильтрации статей
  # @param [ArticleCategory] article_category категория статей
  # @param [ActionController::Parameters] params параметры фильтрации статей
  # @return [Boolean]
  def article_category_chosen?(article_category, params)
    selected_article_category_url(params) == article_category.slug
  end
end

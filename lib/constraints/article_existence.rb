module Constraints
  class ArticleExistence
    def matches?(request)
      country_url = request.path_parameters[:country_url]
      article_category_url = request.path_parameters[:article_category_url]
      country_id = Country.find_by(slug: country_url).id if country_url.present?
      article_category_id = ArticleCategory.find_by(slug: article_category_url).id if article_category_url.present?

      Article.exists?(article_category_id: article_category_id, country_id: country_id)
    end
  end
end

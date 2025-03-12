class ArticlesFilterUrlGenerator

  def initialize(params, request_path)
    @params = params
    @request_path = request_path
  end

  def perform
    path = @params[:url].presence || @request_path

    path =
      if @params[:country_or_category_url].present?
        "#{UrlsHelper.frontend_articles_path}/#{@params[:country_or_category_url]}"
      elsif @params[:country_url].present? || @params[:article_category_url].present?
        country_exist = @params[:country_url].present? && Country.exists?(slug: @params[:country_url])
        article_category_exist = @params[:article_category_url].present? && ArticleCategory.exists?(slug: @params[:article_category_url])

        if country_exist && article_category_exist
          UrlsHelper.frontend_article_category_and_country_articles_path(@params[:country_url], @params[:article_category_url])
        elsif country_exist
          UrlsHelper.frontend_country_articles_path(@params[:country_url])
        elsif article_category_exist
          UrlsHelper.frontend_article_category_articles_path(@params[:article_category_url])
        else
          UrlsHelper.frontend_articles_path
        end
      else
        # UrlsHelper.frontend_articles_path
        path
      end

    return "#{path}?page=#{@params[:page]}" if @params[:page].present? && @params[:page].to_i > 0
    path
  end
end

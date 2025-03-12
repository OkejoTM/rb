class ArticlesFilterController < ApplicationController
  PAGE_SIZE = 30

  layout 'frontend'

  # GET /articles_list
  def articles_list
    country = country_by_params(params)
    article_category = article_category_by_params(params)
    seo_page = seo_page_by_params(country: country, article_category: article_category)
    pagination = articles_by_params(country: country, article_category: article_category)

    build_breadcrumbs(country: country, article_category: article_category)

    url = ArticlesFilterUrlGenerator.new(params, request.path).perform
    alternative_urls = BasicUri.alternate_urls(url, I18n.locale)

    article_categories_sidebar =
      if country.blank?
        render_to_string partial: 'layouts/frontend/blog/sidebar/categories', layout: false
      else
        ''
      end

    render json: {
        url: url,
        alternative_urls: alternative_urls,
        title: seo_page.title,
        breadcrumbs: (render_to_string partial: 'layouts/frontend/common/breadcrumbs', layout: false),
        article_categories: article_categories_sidebar,
        partial: (render_to_string partial: 'layouts/frontend/blog/listing',
                                   locals: {
                                       title: seo_page.h1,
                                       # edit_path: edit_path,
                                       pagination: pagination,
                                       base_url: url
                                   },
                                   layout: false)
    }
  end

  # GET /articles/:country_or_category_url
  # GET /articles/:country_url/:article_category_url
  def articles
    country = country_by_params(params)
    article_category = article_category_by_params(params)
    @seo_page = seo_page_by_params(country: country, article_category: article_category)
    @pagination = articles_by_params(country: country, article_category: article_category)

    build_breadcrumbs(country: country, article_category: article_category)

    @meta_canonical_path = SeoParams::BasicSeoParams.canonical_path(request)
  end

  private

    def articles_by_params(country:, article_category:)
      articles = SearchArticles.new(country: country, article_category: article_category).perform
      Pagination.new(articles, current_page: params[:page].to_i, page_size: PAGE_SIZE)
    end

    def build_breadcrumbs(country:, article_category:)
      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb t(:index, scope: :articles), UrlsHelper.frontend_articles_path
      add_breadcrumb country.title, country.seo_path if country.present?
      add_breadcrumb article_category.title, article_category.seo_path if article_category.present?
    end

    def seo_page_by_params(country:, article_category:)
      seo_articles_page = articles_seo_page_by_params(country: country, article_category: article_category)
      SeoPage::Presenter.new(seo_articles_page, country)
    end

    def articles_seo_page_by_params(country:, article_category:)
      if article_category.present?
        article_category.seo_articles_page
      elsif country.present?
        SeoArticlesLocationPage.primary
      else
        SeoArticlesIndexPage.primary
      end
    end

    def country_by_params(params)
      country_url = [params[:country_or_category_url], params[:country_url]].compact_blank!.first
      Country.find_by(slug: country_url)
    end

    def article_category_by_params(params)
      article_category_url = [params[:country_or_category_url], params[:article_category_url]].compact_blank!.first
      ArticleCategory.find_by(slug: article_category_url)
    end
end

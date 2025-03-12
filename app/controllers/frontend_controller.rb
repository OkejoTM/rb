class FrontendController < ApplicationController
  include UrlsHelper

  layout 'frontend'

  MAX_POPULAR_COUNTRIES = 5

  COUNTRY_AGENCIES_COUNT = 5
  AGENCY_PROPERTIES_COUNT = 10

  # GET /
  def index
    countries = CountryQuery.order_by_popular_and_properties

    @popular_countries = countries.first(MAX_POPULAR_COUNTRIES)
    @areas_by_continent = countries.offset(MAX_POPULAR_COUNTRIES).group_by(&:continent)

    @filter_options = FilterOptions.new

    render 'index'
  end

  # GET /best_deals
  def best_deals
    best_deals = Property::Presenter.wrap_collection(PropertyQuery.popular_for_sale)

    render partial: 'layouts/frontend/carousel', locals: { properties: best_deals,
                                                           title: t(:best_deals) }
  end

  # GET /:country_url
  def country
    country = Country.find_by(slug: params[:country_url]) || not_found
    if country.is_active?
      template_for_country(country)

      @seo_page = SeoPage::Presenter.new(@template.get_seo_page(@country), @country)

      @agencies = @country.visible_agencies.order(active_and_moderated_properties_count: :asc)
                          .last(COUNTRY_AGENCIES_COUNT).reverse # учесть, что должно быть лого

      @filter_options = FilterOptions.new

      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb @country.title, "#{@country.seo_path}"

      render 'country'
    else
      render_404
    end
  end

  # GET /country_properties/:country_id
  def country_properties
    country = Country.find(params[:country_id]) || not_found

    properties = SearchProperties.new(country_id: country.id).perform
    pagination = Pagination.new(properties,
                                 items_count: country.active_and_moderated_properties_count,
                                 current_page: 1, # всегда показываем на странице страны первую страницу недвижимости
                                 page_size: PropertiesFilterController::PAGE_SIZE)

    render partial: 'layouts/frontend/countries/properties', locals: { country: country, pagination: pagination }
  end

  # GET /agencies/:id
  def agency
    agency = Agency.find_by(slug: params[:agency_url]) || not_found

    if agency.is_active? || current_user.present?
      properties = agency.properties.active.with_associations.for_sale
      @pagination = Pagination.new(properties, current_page: params[:page].to_i, page_size: AGENCY_PROPERTIES_COUNT)

      @seo_params = SeoParams::BasicSeoParams.new.tap do |fp|
        fp.meta_canonical_path = SeoParams::BasicSeoParams.canonical_path(request)
      end

      @seo_page = SeoPage::Presenter.new(agency.seo_agency_page)

      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb t(:index, scope: :agencies), agencies_list_path(locale: I18n.locale)
      add_breadcrumb agency.name

      @agency = Agency::Presenter.new(agency)
      render 'agency'
    else
      render_404
    end
  end

  # GET /:country_url/r/:region_url/:id
  # GET /:country_url/c/:city_url/:id
  # GET /:country_url/:id
  # GET /:country_url/r/:region_url/:id.pdf
  # GET /:country_url/c/:city_url/:id.pdf
  # GET /:country_url/:id.pdf
  def property
    property = Property.find_by(id: params[:id]) || not_found

    if property.is_active? || current_user.present?
      @property = Property::Presenter.new(property)
      @agency = Agency::Presenter.new(property.agency)

      template_for_country(property.country)

      similar_properties = @property.similar_properties
      @pagination = Pagination.new(similar_properties,
                                   items_count: similar_properties.count,
                                   page_size: Property::Presenter::MAX_SIMILAR_PROPERTIES)

      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb @property.country.title, "#{@property.country.seo_path}" if @property.country.present?
      add_breadcrumb @property.region.title, "#{@property.region.seo_path}" if @property.region.present?
      add_breadcrumb @property.city.title, "#{@property.city.seo_path}" if @property.city.present?
      add_breadcrumb @property.property_type.title, "#{@property.seo_path}"

      respond_to do |format|
        format.html { render 'property' }
        format.pdf do
          render pdf: "#{date_format(Date.current, format_type: :file_name_format)}.pdf",
                 title: "#{@property.short_page_title}",
                 layout: 'pdf/common',
                 orientation: 'Landscape',
                 header: {
                   html: {
                     template: 'layouts/pdf/header',
                     layout: 'pdf/common',
                   }
                 },
                 footer: {
                   html: {
                     template: 'layouts/pdf/footer',
                     layout: 'pdf/common'
                   },
                 }
        end
      end
    else
      render_404
    end
  end

  # GET /articles/:country_url/:article_category_url/:article_url
  def article
    country = Country.find_by(slug: params[:country_url])
    article_category = ArticleCategory.find_by(slug: params[:article_category_url])

    # @article = Article.where(article_category_id: article_category&.id, country_id: country&.id).first
    @article = Article.find_by(article_category_id: article_category&.id, country_id: country&.id)

    if @article.present? && (@article.is_active? || current_user.present?)
      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb t(:index, scope: :articles), UrlsHelper.frontend_articles_path
      add_breadcrumb country.title, country.seo_path
      add_breadcrumb article_category.title, '' #"#{country.seo_path}"

      render 'article'
    else
      render_404
    end
  end

  # GET /autocomplete?query=%QUERY
  def autocomplete
    render json: SearchLocations.new(params[:query]).perform(default_countries: Country.popular.to_a).to_json
  end

  # GET /terms
  def terms
    @page = Page.terms

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb @page.title, ''

    render 'page'
  end

  # GET /privacy
  def privacy
    @page = Page.privacy

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb @page.title, ''

    render 'page'
  end

  # GET /favorites
  def favorites
    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t("common.favorite"), frontend_favorites_path

    ids = get_favorites
    property =
      Property.where(id: ids)
        .order(Arel.sql("array_position(array#{ids}, CAST(properties.id AS integer))"))
    wrapped_properties = Property::Presenter.wrap_collection(property)
    render 'favorites', locals: { pagination: wrapped_properties }
  end

  # GET /compare_properties
  def compare_properties
    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t("meta.compare_properties_h1"), compare_properties_path

    properties = get_compare_properties

    residential_prop = Property::Presenter.wrap_collection(properties.residential)
    commercial_prop = Property::Presenter.wrap_collection(properties.commercial)
    land_prop = Property::Presenter.wrap_collection(properties.land)

    residential_attr = residential_prop.map { |tag| ComparePropertyAttributeFormatter.create_property_hash(tag) }
    commercial_attr = commercial_prop.map { |tag| ComparePropertyAttributeFormatter.create_property_hash(tag) }
    land_attr = land_prop.map { |tag| ComparePropertyAttributeFormatter.create_property_hash(tag) }

    residential_attr = ComparePropertyArrayFormatter.format_array(residential_attr)
    commercial_attr = ComparePropertyArrayFormatter.format_array(commercial_attr)
    land_attr = ComparePropertyArrayFormatter.format_array(land_attr)

    render 'compare_properties', locals: {
                                            residentials: residential_attr,
                                            commercials: commercial_attr,
                                            lands: land_attr,
                                          }
  end

  private

    def template_for_country(country)
      @country = Country::Presenter.new(country)
      @template = SeoTemplate::Presenter.new(SeoTemplate.country_main, @country)
    end
end

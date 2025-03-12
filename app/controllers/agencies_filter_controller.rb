class AgenciesFilterController < ApplicationController
  PAGE_SIZE = 30

  layout 'frontend'

  # GET /agencies
  def agencies
    country = nil
    region = nil
    city = nil

    if params[:country_url].present?
      country = Country.find_by(slug: params[:country_url]) || not_found
      if params[:region_url].present?
        region = Region.find_by(slug: params[:region_url]) || not_found
      elsif params[:city_url].present?
        city = City.find_by(slug: params[:city_url]) || not_found
      end
    end

    @seo_page = seo_agencies_page_by_params(country: country, region: region, city: city)

    if @seo_page.present?
      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb t(:index, scope: :agencies), UrlsHelper.frontend_agencies_path
      agencies_breadcrumbs_by_params(country: country, region: region, city: city)

      if params[:country_url].blank?
        @countries_by_continent = @seo_agencies_pages.map(&:object)
                                      .group_by(&:continent)
                                      .each { |_, v| v.sort_by! { |c| c.title } }
      end

      @pagination = Pagination.new(@seo_page.agencies, current_page: params[:page].to_i, page_size: PAGE_SIZE)
      @pagination.items = Agency::Presenter.wrap_collection(@pagination.items.preload(:countries, :contacts, :messengers))

      @seo_params = SeoParams::BasicSeoParams.new.tap do |fp|
        fp.meta_canonical_path = SeoParams::BasicSeoParams.canonical_path(request)
      end

      @current_page = current_page_number

      # @seo_page = SeoPage::Presenter.new(@seo_page)

      @agencies_count = @seo_page.agencies_count

      render 'agencies'
    else
      render_404
    end
  end

  private

    def seo_agencies_page_by_params(country:, region:, city:)
      if region.present?
        @seo_agencies_pages = similar_links(SeoAgenciesPage.active.for_cities(region))
        @seo_agencies_pages_title = t("agencies.agencies_in_cities")

        SeoPage::Presenter.new(region&.seo_agencies_page, region)
      elsif city.present?
        SeoPage::Presenter.new(city&.seo_agencies_page, city)
      elsif country.present?
        @seo_agencies_pages = similar_links(SeoAgenciesPage.active.for_regions(country))
        @seo_agencies_pages_title = t("agencies.agencies_in_regions")

        SeoPage::Presenter.new(country&.seo_agencies_page, country)
      else
        @seo_agencies_pages = SeoAgenciesPage.active.for_countries
        SeoPage::Presenter.new(SeoAgenciesPage.default_page)
      end
    end

    def agencies_breadcrumbs_by_params(country:, region:, city:)
      if region.present?
        add_breadcrumb region.country.title, UrlsHelper.frontend_country_agencies_path(region.country.slug)
        add_breadcrumb region.title, UrlsHelper.frontend_region_agencies_path(region.country.slug, region.slug)
      elsif city.present?
        add_breadcrumb city.country.title, UrlsHelper.frontend_country_agencies_path(city.country.slug)
        add_breadcrumb city.region.title, UrlsHelper.frontend_region_agencies_path(city.country.slug, city.region.slug)
        add_breadcrumb city.title, UrlsHelper.frontend_city_agencies_path(city.country.slug, city.slug)
      elsif country.present?
        add_breadcrumb country.title, UrlsHelper.frontend_country_agencies_path(country.slug)
      end
    end

    def similar_links(seo_pages)
      seo_pages.map { |page| { name: page.object.title, link: page.seo_path } }
    end
end

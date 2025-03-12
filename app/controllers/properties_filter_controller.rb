class PropertiesFilterController < ApplicationController
  PAGE_SIZE = 20

  MAX_PROPERTY_ON_MAP_FOR_USER = 10000
  MAX_PROPERTY_ON_MAP = 500
  MAX_ARTICLES_ON_FILTER = 5

  IS_ADDITIONAL_OFFER = false

  layout 'frontend'

  before_action :prepare_params_for_filter

  # GET /main_search
  def main_search
    redirect_to PropertiesFilterUrlGenerator.new(params).perform
  end

  # GET /:property_supertype
  # GET /:property_supertype/f/:template_slug
  # GET /:country_url/f/:template_slug
  # GET /:country_url
  # GET /:country_url/:property_supertype
  # GET /:country_url/r/:region_url/:property_supertype
  # GET /:country_url/c/:city_url/:property_supertype
  # GET /:country_url/r/:region_url
  # GET /:country_url/c/:city_url
  # GET /:country_url/r/:region_url/f/:template_slug
  # GET /:country_url/c/:city_url/f/:template_slug
  def properties
    country, region, city = *locations_by_params(params)

    params[:city_id] = city.id if city.present?
    params[:region_id] = region.id if region.present?
    params[:country_id] = country.id if country.present?

    location_type, location_presenter = *location_type_and_presenter(country, region, city)

    if location_presenter.blank? || location_presenter.is_active?
      @articles =
        if location_type == SeoTemplate::TYPE_COUNTRIES
          country.visible_articles(I18n.locale).last(MAX_ARTICLES_ON_FILTER)
        end
      @property_supertype = get_supertype_by_params
      params[:property_supertype_id] = @property_supertype.id if @property_supertype.present?

      @filter_options = FilterOptions.new(@property_supertype&.id)

      template = get_seo_template(location_presenter: location_presenter,
                                  location_type: location_type,
                                  property_supertype: @property_supertype&.id) #|| not_found

      not_found if template.blank?

      @seo_page = get_seo_page(template: template, location_presenter: location_presenter)

      properties = properties_by_params(params_for_filter(@seo_page))
      @pagination = get_pagination(properties)
      @properties_count = properties.count

      @filter_properties = SeoParams::FilterProperties.new.tap do |fp|
        fp.type = @property_supertype&.id
        fp.meta_canonical_path = SeoParams::BasicSeoParams.canonical_path(request)
        fp.template = template
      end

      @url = get_url
      @currency = set_currency(template)

      @countries_by_continent = CountryQuery.group_by_continent if @property_supertype.present?

      # @filter_properties.edit_path = get_edit_page_path(country, region, city) if current_user.present?

      build_breadcrumbs(country: country, region: region, city: city,
                        property_supertype: @property_supertype, seo_page: @seo_page)

      render_filter_page(@properties_count)
    else
      render_404
    end
  end


  # GET /properties_list
  def properties_list
    # not_found if params[:query].blank?

    country, region, city = *locations_by_params(params)
    property_supertype = get_supertype_by_params
    params[:property_supertype_id] = property_supertype.id if property_supertype.present?

    properties = properties_by_params(params)
    pagination = get_pagination(properties)
    properties_count = properties.count

    url = get_url

    seo_page = seo_page_by_params(country: country,
                                  region: region,
                                  city: city,
                                  property_supertype: property_supertype&.id)

    # Добавить хлебные крошки
    build_breadcrumbs(country: country, region: region, city: city,
                      property_supertype: property_supertype, seo_page: seo_page)

    render json: {
        url: url,
        alternative_urls: BasicUri.alternate_urls(url, I18n.locale),
        title: seo_page.title,
        h1: seo_page.h1,
        is_need_add_req: IS_ADDITIONAL_OFFER && properties.blank?,
        breadcrumbs: (render_to_string partial: 'layouts/frontend/common/breadcrumbs', layout: false),
        partial: (render_to_string partial: 'layouts/frontend/filter_content/listing',
                                   locals: {
                                       currency: params[:currency],
                                       pagination: pagination,
                                       properties_count: properties_count,
                                       base_url: url
                                   },
                                   layout: false)
    }
  end


  # GET /properties_for_map
  def properties_for_map
    properties = properties_by_params(params).with_coordinates

    bounds = JSON.parse(params[:bounds])
    if bounds["lngNE"] != bounds["lngSW"] && bounds["latNE"] != bounds["latSW"]
      properties = properties.in_area(bounds["latNE"], bounds["lngNE"], bounds["latSW"], bounds["lngSW"])
    end

    max_properties = current_user.blank? ? MAX_PROPERTY_ON_MAP : MAX_PROPERTY_ON_MAP_FOR_USER
    properties = properties.limit(max_properties)

    url = get_url

    render json: {
        url: url,
        properties: properties.map { |property| property.slice(:id, :latitude, :longitude) }
    }
  end


  # GET /property_for_map
  def property_for_map
    property = Property.find(params[:id])

    wrapped_property = Property::Presenter.new(property)
    render json: {
        seo_path: wrapped_property.seo_path,
        format_price: Formatters::PriceFormatter.format_price(wrapped_property, currency: params[:currency]),
        format_price_for_area: Formatters::PriceFormatter.format_price_for_area(wrapped_property, currency: params[:currency]),
        main_picture: wrapped_property.pictures.first.pic.mini.url,
        short_page_title: wrapped_property.short_page_title,
        address: wrapped_property.address
    }
  end

  private

    # Удаляет пробельные символы в значениях params, ключи для которых заканчиваются на _to или _from
    # @TODO: это проблема представления, а не контроллера
    def prepare_params_for_filter
      params.keys.each do |key|
        if key.match?(/.*_(from|to)$/)
          params[key]&.gsub!(/\s/, '')
        end
      end
    end

    def properties_by_params(params)
      SearchProperties.new(params).perform
    end

    def get_pagination(properties)
      Pagination.new(properties, current_page: params[:page].to_i, page_size: PAGE_SIZE)
    end

    def get_seo_template(location_type: nil, location_presenter: nil, property_supertype: nil)
      SeoTemplate::Presenter.by_params(slug: params[:template_slug],
                                     location_presenter: location_presenter,
                                     property_supertype: property_supertype,
                                     location_type: location_type)
    end

    def get_seo_page(template:, location_presenter:)
      SeoPage::Presenter.new(template.get_seo_page(location_presenter), location_presenter)
    end

    def seo_page_by_params(country: nil, region: nil, city: nil, property_supertype: nil)
      location_type, location_presenter = *location_type_and_presenter(country, region, city)

      template = get_seo_template(location_presenter: location_presenter,
                                  location_type: location_type,
                                  property_supertype: property_supertype) #|| not_found

      not_found if template.blank?

      get_seo_page(template: template, location_presenter: location_presenter)
    end

    def params_for_filter(seo_page)
      seo_page.to_params.merge(params.permit)
    end

    def get_currency(template)
      currency = params[:currency] || template.filter_params['currency'] || session[:currency]

      if currency.present?
        if currency.size != CurrencyRate::DEFAULT_CURRENCY.size
          # На случай, если в params[:currency] попадет мусор справа от валюты
          currency = currency.first(CurrencyRate::DEFAULT_CURRENCY.size)
        end
        return currency if currency.in?(CurrencyRate::ACTIVE_CURRENCIES)
      end

      CurrencyRate::DEFAULT_CURRENCY
    end

    def set_currency(template)
      session[:currency] = get_currency(template)
    end

    def get_url
      PropertiesFilterUrlGenerator.new(params).perform
    end

    def get_supertype_by_params
      PropertySupertype.by_slug(params[:property_supertype]) if params[:property_supertype].present?
    end

    def build_breadcrumbs(country:, region:, city:, property_supertype:, seo_page:)
      add_breadcrumb t("common.main_page"), :root_path
      add_breadcrumb country.title, country.seo_path if country.present?
      if region.present?
        add_breadcrumb region.title, region.seo_path
      elsif city.present?
        add_breadcrumb city.region.title, city.region.seo_path
      end
      add_breadcrumb city.title, city.seo_path if city.present?
      add_breadcrumb property_supertype.title, property_supertype.seo_path if property_supertype.present?
      add_breadcrumb seo_page.link_name, seo_page.seo_path unless seo_page.primary?
    end

    def render_filter_page(properties_count)
      respond_to do |format|
        format.html { render 'filter', status: (properties_count > 0 ? :ok : :not_found) }
      end
    end


    def locations_by_params(params)
      country = nil
      region = nil
      city = nil
      if params[:query].present?
        ftp = FullTitleParser.new
        ftp.parse_full_title(params[:query])

        city = ftp.city if ftp.city.present?
        region = ftp.region if ftp.region.present?
        country = ftp.country if ftp.country.present?
      elsif params[:country_url].present?
        country = Country.find_by(slug: params[:country_url]) || not_found

        if params[:region_url].present?
          region = country.regions.find_by(slug: params[:region_url]) || not_found
        end
        if params[:city_url].present?
          city = country.cities.find_by(slug: params[:city_url]) || not_found
        end
      end

      [country, region, city]
    end

    def location_type_and_presenter(country, region, city)
      location_type = nil
      location_presenter = nil
      if city.present? && city.is_active?
        location_type = SeoTemplate::TYPE_CITIES
        location_presenter = City::Presenter.new(city)
      elsif region.present? && region.is_active?
        location_type = SeoTemplate::TYPE_REGIONS
        location_presenter = Region::Presenter.new(region)
      elsif country.present? && country.is_active?
        location_type = SeoTemplate::TYPE_COUNTRIES
        location_presenter = Country::Presenter.new(country)
      end
      [location_type, location_presenter]
    end

  # def get_edit_page_path(country, region, city)
  #   if region.present? && region.is_active?
  #     edit_region_path(region)
  #   elsif city.present? && city.is_active?
  #     edit_city_path(city)
  #   elsif country.present? && country.is_active?
  #     edit_country_path(country)
  #   end
  # end
end

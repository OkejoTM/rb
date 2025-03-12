require 'csv'

class Admin::CitiesController < Admin::BasicAdminController

  init_resource :city
  define_actions :destroy

  # GET /cities
  # GET /cities.json
  def index
    fill_missing_params(params)

    cities = City.all.preload(region: [:country])
    cities = City.filter(cities, params)
    # cities = cities.sort_by { |c| c.title_ru } # потому что .order(title_ru: :asc) для кириллицы не сработал

    if params[:download_csv]
      render plain: to_csv(cities)
    else
      respond_to do |format|
        format.html do
          @pagination = Pagination.new(cities, current_page: params[:page].to_i, page_size: 100)

          params_for_filter

          add_breadcrumb "#{t(:index, scope: :cities)} (#{City.all.count})", :cities_path

          @page_title = t(:index, scope: :cities)
        end
        format.json { render json: cities }
        format.csv { render plain: to_csv(cities) }
      end
    end
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    @city = City.find(params[:id])

    add_breadcrumb t(:index, scope: :cities), :cities_path
    add_breadcrumb @city.title

    @page_title = @city.title

    respond_to do |format|
      format.html
      format.json { render json: @city }
    end
  end

  # GET /cities/new
  # GET /cities/new.json
  def new
    @city = City.new
    @regions = Region.all.order(:title_ru)

    add_breadcrumb t(:index, scope: :cities), :cities_path
    add_breadcrumb t(:new, scope: :cities)

    @page_title = t(:new, scope: :cities)

    respond_to do |format|
      format.html
      format.json { render json: @city }
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.where(id: params[:id]).preload(seo_location_pages: { seo_template: :property_type }).first
    @regions = Region.where(country_id: @city.region.country_id).order(:title_ru)

    add_breadcrumb t(:index, scope: :cities), :cities_path
    add_breadcrumb t(:edit, scope: :cities)

    @page_title = t(:edit, scope: :cities)
  end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(city_params)

    respond_to do |format|
      if @city.save
        format.html { redirect_to @city, notice: t('common.saved') }
        # format.json { render json: @city, status: :created, location: @city }
        format.json { render json: { notice: t('common.saved'),
                                     edit_path: edit_city_path(@city) },
                             status: :created,
                             location: @city }
      else
        format.html do
          @regions = Region.all.order(:title_ru)
          render action: "new"
        end
        format.json { render json: { errors: @city.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.json
  def update
    @city = City.find(params[:id])

    # TODO сделать красиво
    if @city.coming_soon == true && city_params[:coming_soon] == "0"
      @city.update_active_properties_counter
    end

    respond_to do |format|
      if @city.update(city_params)
        format.html { redirect_to @city, notice: t('common.updated') }
        format.json { render json: { url: city_path(@city), notice: t('common.updated') } }
      else
        format.html { render action: "edit" }
        format.json { render json: { errors: @city.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # GET /cities/translations
  def translations
    cities = City.without_translation.order(:id)
    cities = City.filter(cities, params)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(cities, current_page: params[:page].to_i, page_size: 100)

        params_for_filter

        add_breadcrumb t('common.translations')

        @page_title = t('common.translations')

        render 'admin/admin/translations'
      end
    end
  end

  # GET /cities/:city_id/browse_pages
  def browse_pages
    city = City.find(params[:city_id])

    @pagination = Pagination.new(city.seo_location_pages, current_page: params[:page].to_i)
    @pagination.items = SeoPage::Presenter.wrap_collection(@pagination.items)

    @title = "SEO-страницы для #{city.title_genitive}"
    add_breadcrumb "#{t(:index, scope: :cities)} (#{City.all.count})", :cities_path
    add_breadcrumb 'SEO-страницы'

    render 'admin/seo_templates/browse_pages'
  end

  private

    def fill_missing_params(params)
      if params[:region_id].present? && params[:country_id].blank?
        params[:country_id] = Region.find(params[:region_id]).country.id
      end

      if params[:country_id].present? && params[:continent].blank?
        params[:continent] = Country.find(params[:country_id]).continent
      end
    end

    def city_params
      params.require(:city).permit(:remove_image, City.attribute_names(recursive: true))
    end

    def params_for_filter
      @countries = CountryQuery.countries_for_select(continent: params[:continent])

      if params[:country_id].present? && params[:country_id].to_i > 0
        @regions = Country.find(params[:country_id])
                       .regions
                       .map { |r| [r.title_ru, r.id] }
      end
      @locales = I18n.available_locales.map(&:to_s)
    end

    def to_csv(cities)
      I18n.locale = :ru

      CSV.generate(encoding: 'cp1251') do |csv|
        csv << ["Название Ru",
                "Название En",
                "Страна Ru",
                "Регион Ru",
                "Активность",
                "Популярная",
                "Активная недвижимость",
                "Ссылка"]

        cities.each do |city|
          csv << [city.title_ru,
                  city.title_en,
                  city.country.title_ru,
                  city.region.title_ru,
                  city.is_active? ? 1 : 0,
                  city.is_popular? ? 1 : 0,
                  city.active_and_moderated_properties_count,
                  city.seo_path]
        end
      end
    end
end

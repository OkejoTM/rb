require 'csv'

class Admin::CountriesController < Admin::BasicAdminController

  init_resource :country
  define_actions :destroy

  # GET /countries
  # GET /countries.json
  def index
    countries = Country.order(active_and_moderated_properties_count: :desc)
    countries = Country.filter(countries, params)
    # countries = countries.sort_by { |c| c.title_ru } # потому что .order(title_ru: :asc) для кириллицы не сработал

    if params[:download_csv]
      render plain: to_csv(countries)
    else
      respond_to do |format|
        format.html do
          @pagination = Pagination.new(countries, current_page: params[:page].to_i, page_size: 100)

          params_for_filter

          add_breadcrumb "#{t(:index, scope: :countries)} (#{Country.all.count})", :countries_path

          @page_title = t(:index, scope: :countries)
        end
        format.json { render json: countries }
        format.csv { render plain: to_csv(countries) }
      end
    end
  end

  # GET /countries/1
  # GET /countries/1.json
  def show
    @country = Country.find(params[:id])

    add_breadcrumb t(:index, scope: :countries), :countries_path
    add_breadcrumb @country.title

    @page_title = @country.title

    respond_to do |format|
      format.html
      format.json { render json: @country }
    end
  end

  # GET /countries/new
  # GET /countries/new.json
  def new
    @country = Country.new

    add_breadcrumb t(:index, scope: :countries), :countries_path
    add_breadcrumb t(:new, scope: :countries)

    @page_title = t(:new, scope: :countries)

    respond_to do |format|
      format.html
      format.json { render json: @country }
    end
  end

  # GET /countries/1/edit
  def edit
    @country = Country.where(id: params[:id]).preload(seo_location_pages: { seo_template: :property_type }).first
    @cities = @country.cities.order(:title_ru)

    add_breadcrumb t(:index, scope: :countries), :countries_path
    add_breadcrumb t(:edit, scope: :countries)

    @page_title = t(:edit, scope: :countries)
  end

  # POST /countries
  # POST /countries.json
  def create
    @country = Country.new(country_params)

    respond_to do |format|
      if @country.save
        format.html { redirect_to @country, notice: t('common.saved') }
        # format.json { render json: @country, status: :created, location: @country }
        format.json { render json: { notice: t('common.saved'),
                                     edit_path: edit_country_path(@country) },
                             status: :created,
                             location: @country }
      else
        format.html { render action: "new" }
        format.json { render json: { errors: @country.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /countries/1
  # PUT /countries/1.json
  def update
    @country = Country.find(params[:id])
    if (params[:country][:capital] != @country.capital&.id)
      update_capital(@country, params[:country][:capital])
    end

    # TODO сделать красиво
    if @country.coming_soon == true && country_params[:coming_soon] == "0"
      @country.update_active_properties_counter
    end

    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to @country, notice: t('common.updated') }
        format.json { render json: { url: country_path(@country), notice: t('common.updated') } }
      else
        format.html { render action: "edit" }
        format.json { render json: { errors: @country.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # GET /countries/translations
  def translations
    countries = Country.without_translation.order(:id)
    countries = Country.filter(countries, params)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(countries, current_page: params[:page].to_i, page_size: 100)

        params_for_filter

        add_breadcrumb t('common.translations')

        @page_title = t('common.translations')

        render "admin/translations"
      end
    end
  end

  # GET /countries/:country_id/browse_pages
  def browse_pages
    country = Country.find(params[:country_id])

    @pagination = Pagination.new(country.seo_location_pages, current_page: params[:page].to_i)
    @pagination.items = SeoPage::Presenter.wrap_collection(@pagination.items)

    @title = "SEO-страницы для #{country.title_genitive}"
    add_breadcrumb "#{t(:index, scope: :countries)} (#{Country.all.count})", :countries_path
    add_breadcrumb 'SEO-страницы'

    render 'seo_templates/browse_pages'
  end

  private
    def update_capital(country, new_capital_id)
      country.capital&.become_simple_city
      if new_capital_id.present?
        capital = City.find(new_capital_id)
        capital.become_capital
        country.capital = capital
      end
    end

    def country_params
      params.require(:country).permit(:remove_image, Country.attribute_names(recursive: true))
    end

    def params_for_filter
      @locales = I18n.available_locales.map(&:to_s)
    end

    def to_csv(countries)
      I18n.locale = :ru

      CSV.generate(encoding: 'cp1251') do |csv|
        csv << ["Название Ru",
                "Название En",
                "Активность",
                "Популярная",
                "Активная недвижимость",
                "Ссылка"]

        countries.each do |country|
          csv << [country.title_ru,
                  country.title_en,
                  country.is_active? ? 1 : 0,
                  country.is_popular? ? 1 : 0,
                  country.active_and_moderated_properties_count,
                  country.seo_path]
        end
      end
    end
end

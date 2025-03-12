require 'csv'

class Admin::RegionsController < Admin::BasicAdminController

  init_resource :region
  define_actions :destroy

  # GET /regions
  # GET /regions.json
  def index
    regions = Region.all.preload(:country)
    regions = Region.filter(regions, params)
    # regions = regions.sort_by { |c| c.title_ru } # потому что .order(title_ru: :asc) для кириллицы не сработал

    if params[:download_csv]
      render plain: to_csv(regions)
    else
      respond_to do |format|
        format.html do
          @pagination = Pagination.new(regions, current_page: params[:page].to_i, page_size: 100)

          params_for_filter

          add_breadcrumb "#{t(:index, scope: :regions)} (#{Region.all.count})", :regions_path

          @page_title = t(:index, scope: :regions)
        end
        format.json { render json: regions }
        format.csv { render plain: to_csv(regions) }
      end
    end
  end

  # GET /regions/1
  # GET /regions/1.json
  def show
    @region = Region.find(params[:id])
    @region_center = @region.region_center

    add_breadcrumb t(:index, scope: :regions), :regions_path
    add_breadcrumb @region.title

    @page_title = @region.title

    respond_to do |format|
      format.html
      format.json { render json: @region }
    end
  end

  # GET /regions/new
  # GET /regions/new.json
  def new
    @region = Region.new
    @countries = Country.all.order(:title_ru)

    add_breadcrumb t(:index, scope: :regions), :regions_path
    add_breadcrumb t(:new, scope: :regions)

    @page_title = t(:new, scope: :regions)

    respond_to do |format|
      format.html
      format.json { render json: @region }
    end
  end

  # GET /regions/1/edit
  def edit
    @region = Region.where(id: params[:id]).preload(seo_location_pages: { seo_template: :property_type }).first
    @region_center = @region.region_center
    @cities = @region.cities.order(:title_ru)
    @countries = Country.all.order(:title_ru)


    add_breadcrumb t(:index, scope: :regions), :regions_path
    add_breadcrumb t(:edit, scope: :regions)

    @page_title = t(:edit, scope: :regions)
  end

  # POST /regions
  # POST /regions.json
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to @region, notice: t('common.saved') }
        # format.json { render json: @region, status: :created, location: @region }
        format.json { render json: { notice: t('common.saved'),
                                     edit_path: edit_region_path(@region) },
                             status: :created,
                             location: @region }
      else
        format.html do
          @countries = Country.all.order(:title_ru)
          render action: "new"
        end
        format.json { render json: { errors: @region.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /regions/1
  # PUT /regions/1.json
  def update
    @region = Region.find(params[:id])
    if (params[:region][:region_center] != @region.region_center&.id)
      change_region_center
    end

    # TODO сделать красиво
    if @region.coming_soon == true && region_params[:coming_soon] == "0"
      @region.update_active_properties_counter
    end

    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to @region, notice: t('common.updated') }
        format.json { render json: { url: region_path(@region), notice: t('common.updated') } }
      else
        format.html {
          @countries = Country.all.order(:title_ru)
          render action: "edit"
        }
        format.json { render json: { errors: @region.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # GET /regions/translations
  def translations
    regions = Region.without_translation.order(:id)
    regions = Region.filter(regions, params)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(regions, current_page: params[:page].to_i, page_size: 100)

        params_for_filter

        add_breadcrumb t('common.translations')

        @page_title = t('common.translations')

        render "admin/translations"
      end
    end
  end

  # GET /regions/:region_id/browse_pages
  def browse_pages
    region = Region.find(params[:region_id])

    @pagination = Pagination.new(region.seo_location_pages, current_page: params[:page].to_i)
    @pagination.items = SeoPage::Presenter.wrap_collection(@pagination.items)

    @title = "SEO-страницы для #{region.title_genitive}"
    add_breadcrumb "#{t(:index, scope: :regions)} (#{Region.all.count})", :regions_path
    add_breadcrumb 'SEO-страницы'

    render 'seo_templates/browse_pages'
  end

  private

    def region_params
      params.require(:region).permit(:remove_image, Region.attribute_names(recursive: true))
    end

    def change_region_center
      @region.region_center&.become_simple_city
      if params[:region][:region_center].present?
        City.where(id: params[:region][:region_center]).first.become_administative_center
      end
    end

    def params_for_filter
      @countries = CountryQuery.countries_for_select

      @locales = I18n.available_locales.map(&:to_s)
    end

    def to_csv(regions)
      I18n.locale = :ru

      CSV.generate(encoding: 'cp1251') do |csv|
        csv << ["Название Ru",
                "Название En",
                "Страна Ru",
                "Активность",
                "Популярная",
                "Активная недвижимость",
                "Ссылка"]

        regions.each do |region|
          csv << [region.title_ru,
                  region.title_en,
                  region.country.title_ru,
                  region.is_active? ? 1 : 0,
                  region.is_popular? ? 1 : 0,
                  region.active_and_moderated_properties_count,
                  region.seo_path]
        end
      end
    end
end

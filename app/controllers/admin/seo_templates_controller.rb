class Admin::SeoTemplatesController < Admin::BasicAdminController
  # skip_before_action :verify_authenticity_token, only: [:add_locations, :add_all_locations,
  #                                                       :remove_locations, :remove_all_locations]

  add_breadcrumb I18n.t("common.main_page"), '/admin' #:admin
  add_breadcrumb I18n.t("seo_templates.index"), '/seo_templates' #:seo_templates

  # GET /seo_templates
  def index
    seo_templates = SeoTemplate.all
    @seo_templates = SeoTemplate.filter(seo_templates, params)
                         .eager_load(:countries, :regions, :cities,
                                     :seo_templates_group, :property_type, :property_supertype)

    property_types

    @page_title = t(:index, scope: :seo_templates)
  end

  # GET /seo_templates/new
  # GET /seo_templates/new.json
  def new
    @template = SeoTemplate.new

    property_types

    @filter_options = FilterOptions.new

    @property_tag_categories = PropertyTagCategory.preload(:property_tags)

    @page_title = t(:new, scope: :seo_templates)

    add_breadcrumb I18n::t("seo_templates.new")
  end

  # GET /seo_templates/:id/edit
  def edit
    @template = SeoTemplate.find(params[:id])

    property_types

    @filter_options = FilterOptions.new

    @property_tag_categories = PropertyTagCategory.preload(:property_tags)

    @page_title = t(:edit, scope: :seo_templates)

    add_breadcrumb @template.name, edit_seo_template_path(@template)
  end

  # POST /seo_templates
  def create
    @template = SeoTemplate.new(seo_template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to seo_templates_path, notice: t('common.saved') }
        format.json { render json: { notice: t('common.saved'),
                                     edit_path: edit_seo_template_path(@template) },
                             status: :created,
                             location: @template }
      else
        format.html { render action: :new }
        format.json { render json: { errors: @template.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /seo_templates/:id
  def update
    @template = SeoTemplate.find(params[:id])

    respond_to do |format|
      if @template.update(seo_template_params)
        format.html { redirect_to @template, notice: t('common.updated') }
        format.json { render json: { notice: t('common.updated') } }
      else
        format.html { render action: "edit" }
        format.json { render json: { errors: @template.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seo_templates/1
  # DELETE /seo_templates/1.json
  def destroy
    @template = SeoTemplate.find(params[:id])
    @template.destroy

    respond_to do |format|
      format.html { redirect_to seo_templates_url(role: params[:role]) }
      format.json { head :no_content }
    end
  end

  # GET /seo_templates/:template_id/browse_pages
  def browse_pages
    @template = SeoTemplate.find(params[:seo_template_id])
    @pagination = Pagination.new(SeoTemplatesContainer.new(@template).all_pages, current_page: params[:page].to_i)

    @title = "#{t(:'seo_templates.seo_pages')} #{@template.name}"
    add_breadcrumb t(:'seo_templates.seo_pages')
  end

  def areas_index
    @template = SeoTemplate.find(params[:id]) if params[:id].present?
    @pagination = Pagination.new(filter_locations, current_page: params[:page].to_i, page_size: 100)

    render partial: 'seo_templates/areas_index'
  end

  def add_locations
    @template = SeoTemplate.find(params[:id])

    if params[:locations].present?

      unless @template.template_location_type == params[:location_type].to_i
        @template.clear_locations
      end

      case params[:location_type].to_i
        when SeoTemplate::TYPE_COUNTRIES
          @template.countries = Country.find(@template.countries.ids.map(&:to_s) | params[:locations])
        when SeoTemplate::TYPE_REGIONS
          @template.regions = Region.find(@template.regions.ids.map(&:to_s) | params[:locations])
        when SeoTemplate::TYPE_CITIES
          @template.cities = City.find(@template.cities.ids.map(&:to_s) | params[:locations])
        else
          []
      end

      @template.template_location_type = params[:location_type].to_i

      respond_to do |format|
        if @template.save
          format.json { render json: true }
        else
          format.json { render json: { errors: @template.errors.messages }, status: :unprocessable_entity }
        end
      end
    end
  end

  def add_all_locations
    @template = SeoTemplate.find(params[:id])

    unless @template.template_location_type == params[:location_type].to_i
      @template.clear_locations
    end

    case params[:location_type].to_i
      when SeoTemplate::TYPE_COUNTRIES
        @template.countries = Country.filter(Country.all, area_index_params)
      when SeoTemplate::TYPE_REGIONS
        @template.regions = Region.filter(Region.all.preload(:country), area_index_params)
      when SeoTemplate::TYPE_CITIES
        @template.cities = City.filter(City.all.preload(region: [:country]), area_index_params)
      else
        []
    end

    @template.template_location_type = params[:location_type].to_i

    respond_to do |format|
      if @template.save
        format.json { render json: true }
      else
        format.json { render json: { errors: @template.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  def remove_locations
    @template = SeoTemplate.find(params[:id])

    if params[:locations].present?
      case params[:location_type].to_i
        when SeoTemplate::TYPE_COUNTRIES
          @template.countries = Country.find(@template.countries.ids.map!(&:to_s) - params[:locations])
        when SeoTemplate::TYPE_REGIONS
          @template.regions = Region.find(@template.regions.ids.map!(&:to_s) - params[:locations])
        when SeoTemplate::TYPE_CITIES
          @template.cities = City.find(@template.cities.ids.map!(&:to_s) - params[:locations])
        else
          []
      end

      respond_to do |format|
        if @template.save
          format.json { render json: true }
        else
          format.json { render json: { errors: @template.errors.messages }, status: :unprocessable_entity }
        end
      end
    end
  end

  def remove_all_locations
    @template = SeoTemplate.find(params[:id])

    respond_to do |format|
      if @template.update(countries: [], regions: [], cities: [])
        format.json { render json: true }
      else
        format.json { render json: { errors: @template.errors.messages }, status: :unprocessable_entity }
      end
    end
  end



  # GET /seo_templates/area_fields_modal_content
  def area_fields_modal_content
    page = SeoLocationPage.find(params[:page_id])

    template_fieldset = page.default_page
    respond_to do |format|
      format.html {
        render partial: 'admin/seo_templates/area_fields_modal_content',
               locals: {
                         page: page,
                         template_fieldset: template_fieldset
               }
      }
    end
  end

  # PUT /seo_templates/update_seo_page
  def update_seo_page
    page = SeoLocationPage.find(params[:seo_location_page][:id])

    respond_to do |format|
      if page.update(page_params)
        format.json { render json: { seo_page: page } }
      else
        format.json { render json: { errors: page.errors.messages }, status: :unprocessable_entity }
      end
    end
  end



  private
    def seo_template_params
      params.require(:seo_template).permit(SeoTemplate.attribute_names(recursive: true), property_tag_ids: []).tap do |whitelisted|
        filter_params = params.to_unsafe_h[:seo_template][:filter_params]
        whitelisted[:filter_params] = filter_params if filter_params.present?
      end
    end

    def page_params
      params.require(:seo_location_page).permit(SeoLocationPage.attribute_names(recursive: true))
    end

    def area_index_params
      params.permit(:country_id, :region_id, :has_active_property, :has_property, :with_seo_template, :query)
    end

    def filter_locations
      case params[:location_type].to_i
        when SeoTemplate::TYPE_COUNTRIES
          Country.filter(Country.all, area_index_params)
        when SeoTemplate::TYPE_REGIONS
          Region.filter(Region.all.preload(:country), area_index_params)
        when SeoTemplate::TYPE_CITIES
          City.filter(City.all.preload(region: [:country]), area_index_params)
        else
          []
      end
    end

    def property_types
      @property_supertypes = PropertySupertype.pluck(:title_ru, :id)
      @property_type_groups = PropertyTypeGroup.pluck(:title_ru, :id)
      @property_types = PropertyType.pluck(:title_ru, :id)

      @seo_templates_groups = SeoTemplatesGroup.order(:title_ru).pluck(:title_ru, :id)
    end
end

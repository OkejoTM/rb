class Admin::PropertiesController < Admin::BasicAdminController
  skip_before_action :authorize_user!, only: %i[edit update destroy]

  # GET /properties
  # GET /properties.json
  def index
    properties = authorized_scope(Property.all).preload(:agency)
    properties = Property.filter(properties, params)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(properties, current_page: params[:page].to_i, page_size: 100)

        options_for_filter

        breadcrumb_additional_info = "(#{Property.count})" if allowed_to?(:info?)
        add_breadcrumb "#{t(:index, scope: :properties)} #{breadcrumb_additional_info}", :properties_path

        @page_title = t(:index, scope: :properties)
      end
      format.json { render json: properties }
    end
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    property = Property.find_by(id: params[:id]) || not_found
    property = Property::Presenter.new(property)

    redirect_to property.seo_path
  end

  # GET /properties/new
  # GET /properties/new.json
  def new
    setup_new_variables

    add_breadcrumb t(:index, scope: :properties), :properties_path
    add_breadcrumb t(:new, scope: :properties)

    @page_title = t(:new, scope: :properties)

    respond_to do |format|
      format.html
      format.json { render json: @property }
    end
  end

  # GET /properties/1/edit
  def edit
    @property = Property.find_by(id: params[:id]) || not_found
    authorize! @property

    setup_edit_variables

    add_breadcrumb t(:index, scope: :properties), :properties_path
    add_breadcrumb t(:edit, scope: :properties)

    @page_title = t(:edit, scope: :properties)

  end

  # POST /properties
  # POST /properties.json
  def create
    @property = Property.new(property_params)

    respond_to do |format|
      if @property.save

        create_new_images(@property)

        setup_new_variables
        format.html { redirect_to @property, notice: t('common.saved') }
        # format.json { render json: @property, status: :created, location: @property }
        format.json { render json: { notice: t('common.saved'),
                                     edit_path: edit_property_path(@property) },
                             status: :created,
                             location: @property }
      else
        setup_new_variables
        format.html { render action: "new" }
        format.json { render json: { errors: @property.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /properties/1
  # PUT /properties/1.json
  def update
    @property = Property.find(params[:id])
    authorize! @property

    respond_to do |format|
      if @property.update(property_params)

        create_new_images(@property)
        update_priority_images(property_params[:pictures_attributes])

        setup_edit_variables
        format.html { redirect_to edit_property_path(@property) }
        format.json do
          render json: {
            url: @property.seo_path,
            notice: t('common.updated'),
            photos: render_to_string(partial: '/admin/properties/form/thumbnail.html.erb',
                                     collection: @property.pictures,
                                     as: :picture)
          }
        end

      else
        setup_edit_variables
        format.html { render action: "edit" }
        format.json { render json: { errors: @property.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property = Property.find(params[:id])
    authorize! @property

    @property.destroy

    respond_to do |format|
      format.html { redirect_to properties_url(role: params[:role]) }
      format.json { head :no_content }
    end
  end

  # GET /properties/same
  def same
    authorize! Property, to: :filter?

    @properties = []
    # Property.all.order(:h1_ru).each do |property|
    #   if property.h1_ru.present? && (Property.where(h1_ru: property.h1_ru).count > 1 ||
    #       Property.where(h1_en: property.h1_en).count > 1)
    #     @properties << property
    #   end
    # end

    @properties = Property.select(:h1_ru).group(:h1_ru).having("count(*) > 1")

    add_breadcrumb t(:index, scope: :properties), :properties_path
    add_breadcrumb t(:same, scope: :properties)

    @page_title = t(:same, scope: :properties)

    respond_to do |format|
      format.html
    end
  end

  # GET /properties/attributes
  def attributes
    authorize! Property, to: :filter?

    @dictionary = {}
    # excluded_keys_ru = ["Цена продажи", "Цена за кв.м.", "Площадь участка", "Площадь дома", "Площадь", "Оборудование",
    #                     "Контактное лицо", "Комплекс", "Компания", "Дополнительные характеристики", "Адрес",
    #                     "Финансирование и управление", "Срок завершения строительства", "Объект сдан в аренду"]
    # excluded_keys_en = ["Sale price", "Price per square meter", "Plot area", "Plot Area", "House Area", "Floor Area", "Area", "Facilities",
    #                     "Contact person", "Complex", "Company", "Additional characteristics", "Address",
    #                     "Finance and management", "Year of building finish", "Property is rented"]
    excluded_keys_ru = ["Цена за кв.м.", "Оборудование",
                        "Контактное лицо", "Комплекс", "Компания", "Дополнительные характеристики", "Адрес",
                        "Финансирование и управление", "Срок завершения строительства", "Объект сдан в аренду"]
    excluded_keys_en = ["Price per square meter", "Facilities",
                        "Contact person", "Complex", "Company", "Additional characteristics", "Address",
                        "Finance and management", "Year of building finish", "Property is rented"]

    done_keys_ru = ["Цена продажи", "Площадь участка", "Площадь дома", "Площадь",
                    "Этаж", "Этажность", "Этажность здания", "Количество спален", "Количество ванных",
                    "Всего комнат", "под жилую застройку", "под коммерческую застройку", "сельское хозяйство",
                    "Продается с готовым бизнесом", "На участке есть постройки", "Год постройки", "Цена по запросу",
                    "Расположение", "Месторасположение", "Тип недвижимости",
                    "До продовольственных магазинов", "До подъемника", "До пляжа", "До моря", "До метро",
                    "До медучреждений", "До исторического центра города", "До границы", "До вокзала",
                    "До ближайшего крупного населенного пункта", "До аэропорта"]
    done_keys_en = ["Sale price", "Plot area", "Plot Area", "House Area", "Floor Area", "Area", "Level", "Storey",
                    "Levels totally", "Number of storeys", "Number of bedrooms", "Number of bathrooms",
                    "Total Rooms", "for residential development", "for commercial development", "agricultural",
                    "Business on sale", "There're building on the land plot", "Year of build", "Price on request",
                    "Location", "Property type",
                    "to food stores", "Destination to the ski lift", "to beach", "Destination to the sea", "to metro station",
                    "to medical facilities", "to historical city center", "to state border", "to railroad station",
                    "to nearest big city", "to airport", "Destination to the airport"]

    excluded_keys_ru += done_keys_ru
    excluded_keys_en += done_keys_en

    part_of_keys_ru = ["Строящийся объект", "Новый дом", "Вторичная недвижимость"]
    part_of_keys_en = ["Off-plan", "New building", "Resale"]

    splited_keys_ru = ["Характеристики участка", "Отдых и инфраструктура", "Месторасположение", "Вид", "Планировка и помещения"]
    splited_keys_en = ["Plot characteristics", "Leisure and Infrastructure", "Location", "View characteristics", "Spaces in & around"]

    Property.all.each do |p|
      fill_dictionary(p, p.attributes_ru, excluded_keys_ru, splited_keys_ru, part_of_keys_ru)
      fill_dictionary(p, p.attributes_en, excluded_keys_en, splited_keys_en, part_of_keys_en)
    end

    add_breadcrumb t(:index, scope: :properties), :properties_path
    add_breadcrumb t(:attributes, scope: :properties)

    @page_title = t(:attributes, scope: :properties)

    render 'properties/attributes'
  end

  # GET /properties/far_property
  def far_property
    authorize! Property, to: :filter?

    properties = Property.have_full_location.where("properties.longitude != 0 AND properties.latitude != 0")
    properties = properties.filter(properties, params)

    far_properties = []

    properties.each do | property |
      distance = property.city&.find_far_distance
      if property.distance_to_city > distance
        far_properties << property
      end
      if far_properties.count >= MAX_FAR_COUNT
        break;
      end
    end

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(far_properties , current_page: params[:page].to_i, page_size: 50)

        options_for_filter

        add_breadcrumb t(:index, scope: :properties), :properties_path

        count_properties =
          if far_properties.count >= MAX_FAR_COUNT
            " > " + MAX_FAR_COUNT.to_s
          else
            far_properties.count.to_s
          end

        add_breadcrumb "#{t(:far_property, scope: :properties)} (#{count_properties})"

        @page_title = t(:far_property, scope: :properties)
      end
    end
  end

  # GET /properties/for_moderation
  def for_moderation
    authorize! Property, to: :filter?

    properties = Property.all.preload(:agency).order(:id)

    params[:moderated_choice] = "false" if params[:moderated_choice].nil?

    properties = Property.filter(properties, params)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(properties, current_page: params[:page].to_i, page_size: 15)

        @property_from_types = PropertyType.order(:title_ru)

        options_for_filter

        add_breadcrumb t(:index, scope: :properties), :properties_path

        add_breadcrumb "#{t(:for_moderation, scope: :properties)} (#{properties.count})"

        @page_title = t(:for_moderation, scope: :properties)
      end
    end
  end

  # GET /properties/no_location
  def no_location
    authorize! Property, to: :filter?

    properties = Property.where('NOT (country_id IS NULL) AND region_id IS NULL AND city_id IS NULL')
    @count_no_location = properties.count
    @pagination = Pagination.new(properties, current_page: params[:page].to_i, page_size: 100)

    add_breadcrumb t(:index, scope: :properties), :properties_path
    add_breadcrumb t(:no_location, scope: :properties)

    @page_title = t(:no_location, scope: :properties)

    respond_to do |format|
      format.html
      @countries = CountryQuery.countries_for_select
      @agencies = AgencyQuery.agencies_for_select
      format.json { render json: @properties }
    end
  end

  private

    MAX_FAR_COUNT = 500

    def property_params
      params.require(:property).permit(Property.attribute_names(recursive: true),
                                       location_type_ids: [], property_tag_ids: [])
    end

    def update_priority_images(params)
      params&.values&.each_with_index do |value, index|
        # С текущей версткой _destroy никогда не придет, но все равно оставил на всякий случай
        if value[:_destroy].blank? || value[:_destroy] == "false"
          pic = Picture.find(value[:id])
          pic.priority = index
          pic.save
        end
      end
    end

    def create_new_images(property)
      params.dig(:property, :picture, :pic)&.each do |a|
        property.pictures.create!(pic: a)
      end
    end

    def fill_dictionary(p, attributes, excluded_keys, splited_keys, part_of_keys)
      attributes.each do |attr_key, attr_value|
        unless @dictionary.keys.include?(attr_key) || excluded_keys.include?(attr_key) ||
            part_of_keys.any? { |i| attr_key.include?(i) }
          @dictionary[attr_key] = []
        end

        if splited_keys.include?(attr_key)
          attr_value.split(',').map { |e| Parser.delete_trailing_spaces(e) }.each do |val|
            unless @dictionary[attr_key]&.include?(val)
              unless @dictionary[attr_key].nil?
                @dictionary[attr_key] << val
              end
            end
          end
        else
          unless @dictionary[attr_key]&.include?(attr_value)
            unless @dictionary[attr_key].nil?
              @dictionary[attr_key] << attr_value
            end
          end
        end

      end
    end

    def options_for_filter
      @countries = CountryQuery.countries_for_select

      if params[:country_id].present? && params[:country_id].to_i > 0
        @regions = Country.find(params[:country_id])
                       .regions
                       .map { |r| [r.title_ru, r.id] }
      end

      if params[:region_id].present? && params[:region_id].to_i > 0
        @cities = Region.find(params[:region_id])
                      .cities
                      .map { |c| [c.title_ru, c.id] }
      end

      @agencies = AgencyQuery.agencies_for_select

      @location_types = LocationType.all
                            .select(:id, :title_ru).order(title_ru: :asc)
                            .pluck(:title_ru, :id)

      @property_supertypes = PropertySupertype.pluck(:title_ru, :id)
      @property_type_groups = PropertyTypeGroup.pluck(:title_ru, :id)
      @property_types = PropertyType.pluck(:title_ru, :id)
    end

    def setup_edit_variables
      @property = Property::Presenter.new(@property)
      @updated_by = User.where(id: @property.updated_by).first
      @created_by = User.where(id: @property.created_by).first
      @agencies = Agency.order(:name_ru)
      @countries = Country.order(:title_ru).preload(:regions)
      @regions = @property.country.present? ? @property.country.regions.order(:title_ru) : []
      @cities = @property.region.present? ? @property.region.cities&.order(:title_ru) : []
      @filter_options = FilterOptions.new
      @property_types = PropertyType.order(:title_ru)
      @location_types = LocationType.order(:title_ru)
      @property_tag_categories = PropertyTagCategory.preload(:property_tags)
    end

    def setup_new_variables
      @property = Property.new
      @agencies = Agency.order(:name_ru)

      @countries = Country.order(:title_ru).preload(:regions)
      @regions = []
      @cities = []

      @filter_options = FilterOptions.new

      @property_types = PropertyType.order(:title_ru)
      @location_types = LocationType.order(:title_ru)

      @property_tag_categories = PropertyTagCategory.preload(:property_tags)
    end
end

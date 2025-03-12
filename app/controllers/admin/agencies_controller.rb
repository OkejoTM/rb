class Admin::AgenciesController < Admin::BasicAdminController

  skip_before_action :authorize_user!, only: %i[edit] # rubocop:disable Rails/LexicallyScopedActionFilter
  init_resource :agency
  define_actions :index, :show, :new, :edit, :destroy

  # POST /agencies
  # POST /agencies.json
  def create
    @agency = Agency.new(object_params)

    respond_to do |format|
      if @agency.save
        format.html
        format.json { render :show,
                             locals: { agency: @agency,
                                       notice: t('common.saved'),
                                       edit_path: edit_agency_path(@agency) },
                             status: :created,
                             location: @agency }
      else
        format.html
        format.json { render json: { errors: @agency.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /agencies/1
  # PUT /agencies/1.json
  def update
    @agency = Agency.find(params[:id])

    respond_to do |format|
      if @agency.update(object_params)
        # format.html { redirect_to @agency, notice: 'Агентство успешно обновлено.' }
        format.html
        format.json { render :show,
                             locals: { agency: @agency,
                                       notice: t('common.updated') },
                             status: :ok,
                             location: @agency }
      else
        format.html { render action: "edit" }
        format.json { render json: { errors: @agency.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  # GET /agencies/last
  def last
    days = params[:created_date].present? ? params[:created_date][:date].to_date : Date.today
    agencies = Agency.where('created_at >= ?', days)

    @pagination = Pagination.new(agencies, current_page: params[:page].to_i, page_size: 100)

    add_breadcrumb t(:index, scope: :agencies), :agencies_path
    add_breadcrumb t(:last, scope: :agencies)

    @page_title = t(:last, scope: :agencies)
  end

  # GET /agencies/translations
  def translations
    agencies = Agency.order(:id)

    respond_to do |format|
      format.html do
        @pagination = Pagination.new(agencies, current_page: params[:page].to_i, page_size: 100)

        add_breadcrumb t('common.translations')

        @page_title = t('common.translations')
      end
    end
  end

  private

    def index_hook
      authorize! Agency.all

      @objects = Agency.filter(@objects, params)

      @pagination = Pagination.new(@objects.order(has_contract: :desc), current_page: params[:page].to_i, page_size: 100)

      add_breadcrumb "#{t(:index, scope: :agencies)} (#{Agency.all.count})", :agencies_path

      @page_title = t(:index, scope: :agencies)
    end

    def new_hook
      @object = Agency.new_with_dependencies

      add_breadcrumb t(:index, scope: :agencies), :agencies_path
      add_breadcrumb t(:new, scope: :agencies)

      @page_title = t(:new, scope: :agencies)
    end

    def edit_hook
      @agency = Agency.find_by(id: params[:id]) || not_found
      authorize! @agency

      if allowed_to? :index?
        add_breadcrumb t(:index, scope: :agencies), :agencies_path
      end

      add_breadcrumb t(:edit, scope: :agencies)

      @page_title = t(:edit, scope: :agencies)
    end
end

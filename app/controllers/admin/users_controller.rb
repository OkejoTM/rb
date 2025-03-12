class Admin::UsersController < Admin::BasicAdminController
  init_resource :user
  define_actions :index, :show, :new, :edit, :create, :destroy

  def update
    @object = User.find(params[:id])

    if params[:simulation] == 'on' && allowed_to?(:simulate_role?) && @object.role != params.dig(:user, :role)
      @object.original_role = @object.role
      redirect_path = admin_path
    end

    if @object.update(user_params)
      redirect_to redirect_path || @object, notice: t('common.updated')
    else
      edit_hook
      render :edit, status: :unprocessable_entity
    end
  end

  def switch_off_simulate_mode
    current_user.switch_off_simulate_mode!
    redirect_to request.referer.presence || admin_path
  end

  private

    def index_hook
      # @objects =
      #     if params[:role].present?
      #       add_breadcrumb User.get_russian_role_plural(params[:role]) if can? :index, User
      #       User.where(role: params[:role])
      #     else
      #       User.where.not(role: 'disabled')
      #     end

      # if params[:recently_registered].present? && params[:recently_registered] == 'true'
      #   @objects = @objects.recently_registered
      # end

      @objects = User.filter(@objects, params)

      @pagination = Pagination.new(@objects, current_page: params[:page].to_i, page_size: 30)
      add_breadcrumb "#{t(:index, scope: :users)} (#{User.all.count})", :users_path

      @page_title = t(:index, scope: :users)
    end

    def show_hook
      add_breadcrumb t(:index, scope: :users), :users_path

      add_breadcrumb @object.email

      @page_title = @object.email
    end

    def new_hook
      @agencies = AgencyQuery.agencies_for_select
    end

    def edit_hook
      @agencies = AgencyQuery.agencies_for_select
    end

    def create_hook
      @object.generate_password if @object.encrypted_password.blank?
      @agencies = AgencyQuery.agencies_for_select
    end

    def update_hook
      @agencies = AgencyQuery.agencies_for_select
    end

    def user_params
      params.require(:user).permit(User.attribute_names(recursive: true))
    end
end

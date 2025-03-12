class Admin::ReportsController < Admin::BasicAdminController

  # GET /reports/updated_content
  def updated_content
    @users = User.all

    add_breadcrumb t(:content_report, scope: :reports)
    @page_title = t(:content_report, scope: :reports)
  end

  # GET /reports/updated_content_result
  def updated_content_result
    if params["reports"].blank?
      redirect_to('/reports/updated_content') && (return)
    end

    start_date = Date.parse(params[:reports][:start_date], "%d-%m-%Y")
    end_date =
        if params[:reports][:end_date].present?
          Date.parse(params[:reports][:end_date], "%d-%m-%Y")
        else
          Date.today
        end

    if params[:reports][:user].present?
      @user = User.find(params[:reports][:user])
      properties = properties_by_date_and_user(start_date, end_date, @user)

      @pagination = Pagination.new(properties, current_page: params[:page].to_i, page_size: 100)
      @page_title = t(:user_report, scope: :reports)
      @properties_count = properties.count

      add_breadcrumb t(:content_report, scope: :reports), :updated_content_path
      add_breadcrumb @page_title

      render 'admin/reports/updated_content_for_user'
    else
      users = User.all
      @user_table = generate_user_table(start_date, end_date, users)

      @page_title = t(:users_report, scope: :reports)

      add_breadcrumb t(:content_report, scope: :reports), :updated_content_path
      add_breadcrumb @page_title

      render 'admin/reports/updated_content_for_users'
    end
  end

  private

    def generate_user_json(user, properties_count, seo_templates_count)
      {
          email: user.email,
          id: user.id,
          properties_count: properties_count,
          seo_templates_count: seo_templates_count
      }
    end

    def generate_user_table(start_date, end_date, users)
      result = []
      users.each do |user|
        properties_count = properties_by_date_and_user(start_date, end_date, user).count
        seo_templates_count = seo_templates_by_date_and_user(start_date, end_date, user).count

        if properties_count > 0 || seo_templates_count > 0
          result << generate_user_json(user, properties_count, seo_templates_count)
        end
      end
      result
    end

    def properties_by_date_and_user(start_date, end_date, user)
      Property.where("((created_at BETWEEN ? AND ?) OR (updated_at BETWEEN ? AND ?)) AND updated_by = ?",
                     start_date, end_date, start_date, end_date, user.id)
    end

    def seo_templates_by_date_and_user(start_date, end_date, user)
      SeoTemplate.where("((created_at BETWEEN ? AND ?) OR (updated_at BETWEEN ? AND ?)) AND updated_by = ?",
                        start_date, end_date, start_date, end_date, user.id)
    end

    # Нужно явно указать цель авторизации, т.к. не существует сущности Report
    def implicit_authorization_target
      :report
    end
end

module Admin::ReportsHelper
  def generate_date_interval_title(start_date, end_date)
    "#{t(:users_report_title, scope: :reports)} #{start_date} - #{generate_end_date(end_date)}"
  end

  def generate_user_title(user, properties_count, start_date, end_date)
    "#{t(:user_report_title, scope: :reports)} #{get_name_by_email(user.email)}:
              #{start_date} - #{generate_end_date(end_date)} (#{properties_count})"
  end

  private
    def generate_end_date(end_date)
      end_date.presence || t(:today, scope: :common)
    end

    def get_name_by_email(email)
      email[0..email.rindex("@") - 1]
    end
end

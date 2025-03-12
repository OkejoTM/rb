class Admin::ReportPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

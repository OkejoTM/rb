class Admin::MonitorPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

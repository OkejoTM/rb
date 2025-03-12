class Admin::PropertyTagPolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

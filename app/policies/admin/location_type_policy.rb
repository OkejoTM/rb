class Admin::LocationTypePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

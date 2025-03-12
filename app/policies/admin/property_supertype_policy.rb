class Admin::PropertySupertypePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

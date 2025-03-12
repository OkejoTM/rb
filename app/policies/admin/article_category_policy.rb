class Admin::ArticleCategoryPolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

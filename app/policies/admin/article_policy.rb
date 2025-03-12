class Admin::ArticlePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

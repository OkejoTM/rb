class Admin::PropertyTypePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end

  def index?
    user.admin? || user.content_manager? || user.agent? || user.seller_person?
  end
end

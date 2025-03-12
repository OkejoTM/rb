class Admin::PicturePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager? || user.agent? || user.seller_person?
  end
end

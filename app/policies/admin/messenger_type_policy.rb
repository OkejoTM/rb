class Admin::MessengerTypePolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager?
  end
end

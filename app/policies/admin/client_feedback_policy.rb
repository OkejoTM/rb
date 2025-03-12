class Admin::ClientFeedbackPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

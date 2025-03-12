class Admin::AgencyBidPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

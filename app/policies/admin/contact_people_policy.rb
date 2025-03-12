class Admin::ContactPeoplePolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

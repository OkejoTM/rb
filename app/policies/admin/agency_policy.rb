class Admin::AgencyPolicy < Admin::BasicPolicy
  def manage?
    user.admin? || user.content_manager? || user.agent?
  end

  def index?
    user.admin? || user.content_manager?
  end

  def edit?
    user.admin? || user.content_manager? || (user.agent? && user.agency_id == record.id)
  end
end

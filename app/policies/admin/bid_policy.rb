class Admin::BidPolicy < Admin::BasicPolicy
  relation_scope do |relation|
    case user.role
      when 'admin', 'content_manager'
        relation
      when 'agent'
        relation.where(property_id: Property.where(agency_id: user.agency_id).select(:id))
      when 'seller_person'
        relation.where(property_id: Property.where(created_by: user.id).select(:id))
      else
        relation.none
    end
  end

  def index?
    user.admin? || user.agent? || user.seller_person?
  end

  def bid_user?
    user.admin? || user.agent? || user.seller_person?
  end

  def manage?
    user.admin? || user.agent? || user.seller_person?
  end

  def search?
    user.admin?
  end
end

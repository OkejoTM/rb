class Admin::PropertyPolicy < Admin::BasicPolicy
  relation_scope do |relation|
    case user.role
      when 'admin', 'content_manager'
        relation
      when 'agent'
        relation.where(agency_id: user.agency_id)
      when 'seller_person'
        relation.where(created_by: user.id)
      else
        relation.none
    end
  end

  def edit?
    user.admin? || user.content_manager? || (user.agent? && user.agency_id == record.agency_id) || (user.seller_person? && user.id == record.created_by)
  end

  def update?
    user.admin? || user.content_manager? || (user.agent? && user.agency_id == record.agency_id) || (user.seller_person? && user.id == record.created_by)
  end

  def manage?
    user.admin? || user.content_manager? || user.agent? || user.seller_person?
  end

  def additional_links?
    user.admin? || user.content_manager?
  end

  def info?
    user.admin? || user.content_manager?
  end

  def filter?
    user.admin? || user.content_manager?
  end
end

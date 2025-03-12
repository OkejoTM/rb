class Admin::CommentPolicy < Admin::BasicPolicy
  relation_scope do |relation|
    case user.role
      when 'admin'
        relation.where(created_by: User.where(role: 'admin').select(:id))
      when 'content_manager'
        relation.none
      when 'agent'
        relation.where(created_by: User.where(agency_id: user.agency_id).where.not(role: 'admin').select(:id))
      when 'seller_person'
        relation.where(created_by: user.id)
      else
        relation.none
    end
  end

  def manage?
    user.admin? || user.agent? || user.seller_person?
  end
end

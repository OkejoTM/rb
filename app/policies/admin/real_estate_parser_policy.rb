class Admin::RealEstateParserPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

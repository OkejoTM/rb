class Admin::RealEstateParserLogPolicy < Admin::BasicPolicy
  def manage?
    user.admin?
  end
end

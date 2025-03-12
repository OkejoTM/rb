class Admin::BasicPolicy < ApplicationPolicy
  pre_check :allow_admins
  default_rule :manage?
  alias_rule :index?, :create?, :new?, to: :manage?

  def manage?
    user.admin?
  end

  private

    def allow_admins
      allow! if user.admin?
    end
end

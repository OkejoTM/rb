class Admin::UserPolicy < Admin::BasicPolicy
  def simulate_role?
    user.admin?
  end

  def edit?
    user.admin? || user.content_manager?
  end

  def update?
    user.admin? || user.content_manager?
  end

  def manage?
    user.admin? || user.content_manager?
  end

  def show?
    user.admin? || user.content_manager?
  end

  def switch_off_simulate_mode?
    true
  end

  def filter?
    user.admin?
  end
end

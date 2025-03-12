module Admin::UsersHelper
  def roles
    t('users.roles').invert
  end

  def role(role)
    t("users.roles.#{role}")
  end
end

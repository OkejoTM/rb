class Admin::AdminPolicy < Admin::BasicPolicy
  def main?
    true
  end

  def image_upload?
    true
  end

  def info?
    user.admin? || user.content_manager?
  end
end

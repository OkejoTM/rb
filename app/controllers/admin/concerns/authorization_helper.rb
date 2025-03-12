module Admin::Concerns::AuthorizationHelper
  extend ActiveSupport::Concern

  included do
    rescue_from ActionPolicy::Unauthorized, with: :render_401

    verify_authorized # Проверяет чтобы проверка авторизации была вызвана

    authorize :user, through: :current_user # определяет субъекта авторизации (исполнителя)
  end

  private

    def render_401(ex)
      # Exception object contains the following information
      policy = ex.policy #=> policy class, e.g. UserPolicy
      applied_rule = ex.rule #=> applied rule, e.g. :show?

      Rails.logger.warn(policy_warning(current_user.id, policy, applied_rule))

      respond_to do |format|
        format.html { render file: Rails.root.join('public', '401.html').to_s, layout: false, status: :unauthorized }
        format.any  { head :unauthorized }
      end
    end

    def authorize_user!
      authorize!
    rescue ActionPolicy::NotFound => e
      authorize! with: Admin::BasicPolicy
    end

    def policy_warning(id, policy, rule)
      <<-TEXT
        Error 401
        User ##{id} failed to authorize
        policy: #{policy}
        applied_rule: #{rule}
      TEXT
    end
end

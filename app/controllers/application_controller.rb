class ApplicationController < ActionController::Base
  include ApplicationHelper

  # protect_from_forgery with: :exception
  # protect_from_forgery prepend: true
  skip_before_action :verify_authenticity_token, raise: false

  before_action :set_locale
  before_action :set_current_user

  rescue_from ActionController::RoutingError, with: :render_404

  def not_found(message = '')
    raise ActionController::RoutingError.new("Not found! message: #{message}")
  end

  private

    def render_404
      respond_to do |format|
        format.html { render file: Rails.root.join('public', '404.html').to_s, layout: false, status: :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end

    def render_403
      respond_to do |format|
        format.html { render file: Rails.root.join('public', '403.html').to_s, layout: false, status: :not_found }
        format.any  { head :forbidden }
      end
    end

    def after_sign_in_path_for(resource_or_scope)
      # Либо не залогиненный пользователь хотел куда-то зайти, но не смог, его location был заранее сохранен
      # либо на главную админки
      stored_location_for(resource_or_scope) || admin_url
    end

    def after_sign_out_path_for(resource_or_scope)
      root_url(subdomain: false)
    end

    def set_locale
      locale_from_header = extract_locale_from_accept_language_header
      I18n.locale =
          if params[:locale] && locale_exist?(params[:locale].to_sym)
            params[:locale].to_sym
          elsif locale_from_header.present? && locale_exist?(locale_from_header)
            locale_from_header
          else
            I18n.default_locale
          end
    end

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    end

    def locale_exist?(locale)
      I18n.available_locales.include?(locale)
    end

    # def default_url_options
    #   { locale: I18n.default_locale }
    # end

    def set_current_user
      User.current_user = current_user if current_user
    end

    def current_page_number
      return 1 if params[:page].blank? || params[:page].to_i == 0
      params[:page].to_i
    end
end

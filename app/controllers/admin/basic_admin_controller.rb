class Admin::BasicAdminController < ApplicationController
  include ActiveRecordController::Base
  include Admin::Concerns::AuthorizationHelper

  layout 'admin'

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :authorize_user!

  add_breadcrumb I18n::t("common.main_page"), '/admin', only: %i[index show new edit]

  private
    # Важно, чтобы location НЕ сохранялся, если:
    # - Метод запроса не GET (не идемпотентный).
    # - Запрос обрабатывается контроллером Devise, таким как Devise::SessionsController, так как это может вызвать
    # бесконечный цикл перенаправления.
    # - Запрос является Ajax-запросом, так как это может привести к очень неожиданному поведению.
    # - Пользователь уже залогинен и редирект не требуется.
    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && !user_signed_in?
    end

    def store_user_location!
      # Класть путь куда редиректить в сессию (если это не оно самое) и доставать его из сессии
      store_location_for(:user, request.fullpath)
    end
end

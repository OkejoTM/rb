class Admin::RealEstateParsersController < Admin::BasicAdminController
  init_resource :real_estate_parsers
  define_actions :index, :update, :show

  private
    def index_hook
      add_breadcrumb "#{t(:index, scope: :real_estate_parsers)}", :real_estate_parsers_path

      @page_title = t(:index, scope: :real_estate_parsers)
    end
end

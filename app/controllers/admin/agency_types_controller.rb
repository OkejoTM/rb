class Admin::AgencyTypesController < Admin::BasicAdminController

  init_resource :agency_type
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :agency_types), :agency_types_path
      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

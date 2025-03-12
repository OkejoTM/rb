class Admin::LocationTypesController < Admin::BasicAdminController

  init_resource :location_type
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :location_types), :location_types_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

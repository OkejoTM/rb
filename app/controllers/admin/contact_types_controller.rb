class Admin::ContactTypesController < Admin::BasicAdminController

  init_resource :contact_type
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :contact_types), :contact_types_path
      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

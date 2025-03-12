class Admin::PropertySupertypesController < Admin::BasicAdminController

  init_resource :property_supertype
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :property_supertype), :property_supertypes_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

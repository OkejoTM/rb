class Admin::PropertyTypeGroupsController < Admin::BasicAdminController

  init_resource :property_type_group
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def index_hook
      add_breadcrumb t(:index, scope: :property_type_groups), :property_type_groups_path

      @page_title = t(:index, scope: :property_type_groups)

      if params[:property_supertype_id].present?
        @objects = @objects.where(property_supertype_id: params[:property_supertype_id])
      end
    end

    def show_hook
      add_breadcrumb t(:index, scope: :property_type_groups), :property_type_groups_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end

    def new_hook
      add_breadcrumb t(:index, scope: :property_type_groups), :property_type_groups_path
      add_breadcrumb t(:new, scope: :property_type_groups)

      @page_title = t(:new, scope: :property_type_groups)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
    end

    def edit_hook
      add_breadcrumb t(:index, scope: :property_type_groups), :property_type_groups_path
      add_breadcrumb t(:edit, scope: :property_type_groups)

      @page_title = t(:edit, scope: :property_type_groups)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
    end
end

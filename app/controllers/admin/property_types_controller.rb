class Admin::PropertyTypesController < Admin::BasicAdminController

  init_resource :property_type
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def index_hook
      add_breadcrumb t(:index, scope: :property_types), :property_types_path

      @page_title = t(:index, scope: :property_types)

      if params[:property_supertype_id].present?
        @objects = @objects.where(property_supertype_id: params[:property_supertype_id])
      end

      if params[:property_type_group_id].present?
        @objects = @objects.where(property_type_group_id: params[:property_type_group_id])
      end
    end

    def show_hook
      add_breadcrumb t(:index, scope: :property_types), :property_types_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end

    def new_hook
      add_breadcrumb t(:index, scope: :property_types), :property_types_path
      add_breadcrumb t(:new, scope: :property_types)

      @page_title = t(:new, scope: :property_types)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
      @property_type_groups = PropertyTypeGroup.all.collect { |p| [ p.title, p.id ] }
    end

    def edit_hook
      add_breadcrumb t(:index, scope: :property_types), :property_types_path
      add_breadcrumb t(:edit, scope: :property_types)

      @page_title = t(:edit, scope: :property_types)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
      @property_type_groups = PropertyTypeGroup.all.collect { |p| [ p.title, p.id ] }
    end
end

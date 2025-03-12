class Admin::PropertyTagCategoriesController < Admin::BasicAdminController

  init_resource :property_tag_category
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :property_tag_categories), :property_tag_categories_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end

    def new_hook
      add_breadcrumb t(:index, scope: :property_tag_categories), :property_tag_categories_path
      add_breadcrumb t(:new, scope: :property_tag_categories)

      @page_title = t(:new, scope: :property_tag_categories)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
    end

    def edit_hook
      add_breadcrumb t(:index, scope: :property_tag_categories), :property_tag_categories_path
      add_breadcrumb t(:edit, scope: :property_tag_categories)

      @page_title = t(:edit, scope: :property_tag_categories)

      @property_supertypes = PropertySupertype.all.collect { |p| [ p.title, p.id ] }
    end
end

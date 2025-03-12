class Admin::PropertyTagsController < Admin::BasicAdminController

  init_resource :property_tag
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  def sort
    params[:property_tag].each.with_index(1) do |id, index|
      PropertyTag.where(id: id).update_all(position: index)
    end
  end

  private

    def show_hook
      add_breadcrumb t(:index, scope: :property_tags), :property_tags_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end

    def new_hook
      add_breadcrumb t(:index, scope: :property_tags), :property_tags_path
      add_breadcrumb t(:new, scope: :property_tags)

      @page_title = t(:new, scope: :property_tags)

      @property_tag_categories = PropertyTagCategory.all.collect { |p| [ p.title, p.id ] }
    end

    def edit_hook
      add_breadcrumb t(:index, scope: :property_tags), :property_tags_path
      add_breadcrumb t(:edit, scope: :property_tags)

      @page_title = t(:edit, scope: :property_tags)

      @property_tag_categories = PropertyTagCategory.all.collect { |p| [ p.title, p.id ] }
    end

    def index_hook
      add_breadcrumb t(:index, scope: :property_tags), :property_tags_path

      @page_title = t(:index, scope: :property_tags)

      @objects = PropertyTag
                     .all
                     .order(:moderated, :position)
    end

    def object_params
      permitted_params = model.attribute_names(recursive: true).deep_dup
      permitted_params.push(property_tag_alias_attributes: PropertyTagAlias.attribute_names)

      params.require(resource_name).permit(permitted_params)
    end
end

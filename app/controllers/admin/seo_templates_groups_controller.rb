class Admin::SeoTemplatesGroupsController < Admin::BasicAdminController

  init_resource :seo_templates_group
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :seo_templates_groups), :seo_templates_groups_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

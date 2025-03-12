class Admin::ArticleCategoriesController < Admin::BasicAdminController

  init_resource :article_category
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def new_hook
      @object = ArticleCategory.new_with_dependencies

      add_breadcrumb t(:index, scope: :article_categories), :article_categories_path
      add_breadcrumb t(:new, scope: :article_categories)

      @page_title = t(:new, scope: :article_categories)
    end

    def show_hook
      add_breadcrumb t(:index, scope: :article_categories), :article_categories_path
      add_breadcrumb @object.title

      @page_title = @object.title
    end
end

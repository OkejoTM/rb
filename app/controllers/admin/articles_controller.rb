class Admin::ArticlesController < Admin::BasicAdminController

  init_resource :article
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def new_hook
      add_breadcrumb t(:index, scope: :articles), :articles_path
      add_breadcrumb t(:new, scope: :articles)

      @page_title = t(:new, scope: :articles)

      @article_categories = ArticleCategory.pluck(:title_ru, :id)
      @countries = Country.pluck(:title_ru, :id)
    end

    def edit_hook
      add_breadcrumb t(:index, scope: :articles), :articles_path
      add_breadcrumb t(:edit, scope: :articles)

      @page_title = t(:edit, scope: :articles)

      @article_categories = ArticleCategory.pluck(:title_ru, :id)
      @countries = Country.pluck(:title_ru, :id)
    end
end

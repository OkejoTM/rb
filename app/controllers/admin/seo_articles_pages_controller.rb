class Admin::SeoArticlesPagesController < Admin::BasicAdminController

  # GET /seo_articles_pages/1
  # GET /seo_articles_pages/1.json
  def show
    @seo_page = SeoArticlesPage.find(params[:id])

    add_breadcrumb t(:index, scope: :regions), :regions_path
    add_breadcrumb @seo_page.h1

    @page_title = t("seo_articles_pages.show")

    respond_to do |format|
      format.html
      format.json { render json: @seo_page }
    end
  end

  # GET /seo_articles_pages/edit_articles_main
  def edit_articles_main
    @seo_page = SeoArticlesIndexPage.primary || not_found

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t(:edit_articles_main, scope: :seo_articles_pages)

    @page_title = t(:edit_articles_main, scope: :seo_articles_pages)
    @h1 = t(:edit_articles_main, scope: :seo_articles_pages)

    render 'edit'
  end

  # GET /seo_articles_pages/edit_articles_countries_main
  def edit_articles_countries_main
    @seo_page = SeoArticlesLocationPage.primary || not_found

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t(:edit_articles_countries_main, scope: :seo_articles_pages)

    @page_title = t(:edit_articles_countries_main, scope: :seo_articles_pages)
    @h1 = t(:edit_articles_countries_main, scope: :seo_articles_pages)

    render 'edit'
  end

  # GET /seo_articles_pages/edit_articles_categories_main
  def edit_articles_categories_main
    @seo_page = SeoArticlesCategoryPage.primary || not_found

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t(:edit_articles_categories_main, scope: :seo_articles_pages)

    @page_title = t(:edit_articles_categories_main, scope: :seo_articles_pages)
    @h1 = t(:edit_articles_categories_main, scope: :seo_articles_pages)

    render 'edit'
  end

  # PUT /seo_articles_pages/1
  # PUT /seo_articles_pages/1.json
  def update
    @seo_page = SeoArticlesPage.find(params[:id])

    respond_to do |format|
      if @seo_page.update(seo_articles_page_params)
        format.html { redirect_to @seo_page, notice: t('common.updated') }
        format.json { render json: { notice: t('common.updated') } }
      else
        format.html { render action: "edit" }
        format.json { render json: { errors: @seo_page.errors,
                                     notice: t('common.error') },
                             status: :unprocessable_entity }
      end
    end
  end

  private

    def seo_articles_page_params
      params.require(:seo_articles_page).permit(SeoArticlesPage.attribute_names)
    end
end

class Admin::SeoAgenciesPagesController < Admin::BasicAdminController

  # GET /seo_agencies_pages/1
  # GET /seo_agencies_pages/1.json
  def show
    @seo_page = SeoAgenciesPage.find(params[:id])

    add_breadcrumb t(:index, scope: :regions), :regions_path
    add_breadcrumb @seo_page.h1

    @page_title = t("seo_agencies_pages.show")

    respond_to do |format|
      format.html
      format.json { render json: @seo_page }
    end
  end

  # GET /seo_agencies_pages/edit_agencies_main
  def edit_agencies_main
    @seo_page = SeoAgenciesPage.default_page || not_found

    add_breadcrumb t("common.main_page"), :root_path
    add_breadcrumb t(:edit_agencies_main, scope: :seo_agencies_pages)

    @page_title = t(:edit_agencies_main, scope: :seo_agencies_pages)
    @h1 = t(:edit_agencies_main, scope: :seo_agencies_pages)

    render 'edit'
  end

  # PUT /seo_agencies_pages/1
  # PUT /seo_agencies_pages/1.json
  def update
    @seo_page = SeoAgenciesPage.find(params[:id])

    respond_to do |format|
      if @seo_page.update(seo_agencies_page_params)
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

    def seo_agencies_page_params
      params.require(:seo_agencies_page).permit(SeoAgenciesPage.attribute_names)
    end
end

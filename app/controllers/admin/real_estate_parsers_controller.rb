class Admin::RealEstateParsersController < Admin::BasicAdminController
  init_resource :real_estate_parsers
  define_actions :index, :update, :show

  def start
    RealEstateParserJob.perform_later(params[:real_estate_parser_id])
    if @real_estate_parser.is_active?
      RealEstateParserJob.perform_later(@real_estate_parser.id)
      redirect_to real_estate_parsers_path
    else
      redirect_to real_estate_parsers_path, alert: 'Невозможно запустить неактивный парсер.'
    end
  end

  def update
    @real_estate_parser = RealEstateParser.find(params[:id])

    respond_to do |format|
      if @real_estate_parser.update(real_estate_parser_params)
        format.html { redirect_to real_estate_parsers_path, notice: 'Статус парсера успешно обновлен.' }
        format.json { render :show, status: :ok, location: @real_estate_parser }
      else
        format.html { redirect_to real_estate_parsers_path, alert: 'Не удалось обновить статус парсера.' }
        format.json { render json: @real_estate_parser.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def index_hook
      add_breadcrumb "#{t(:index, scope: :real_estate_parsers)}", :real_estate_parsers_path

      @page_title = t(:index, scope: :real_estate_parsers)
    end

    def real_estate_parser_params
      params.require(:real_estate_parser).permit(:is_active)
    end

end

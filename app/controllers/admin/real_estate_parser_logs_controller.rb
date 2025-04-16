class Admin::RealEstateParserLogsController < Admin::BasicAdminController
  init_resource :real_estate_parser_logs
  define_actions :index, :update

  private
    def index_hook
      @objects =
        if params[:real_estate_parser_id].present?
          RealEstateParserLog.where(real_estate_parser_id: params[:real_estate_parser_id])
        else
          RealEstateParserLog.all
        end

      @pagination = Pagination.new(@objects, current_page: params[:page].to_i, page_size: 100)
      add_breadcrumb t(:index, scope: :real_estate_parsers), :real_estate_parsers_path
      add_breadcrumb "#{t(:index, scope: :real_estate_parser_logs)} (#{RealEstateParserLog.all.count})",
                     real_estate_parser_real_estate_parser_logs_path(real_estate_parser_id: params[:real_estate_parser_id])

      @page_title = t(:index, scope: :real_estate_parser_logs)
    end
end

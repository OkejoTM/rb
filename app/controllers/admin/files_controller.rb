class Admin::FilesController < Admin::BasicAdminController
  def open_in_browser
    file_path = Rails.root.join('log', 'parsers', "real_estate_parser_#{RealEstateParserLog.find_by(id: params[:id]).real_estate_parser_id}", "log_#{params[:id]}.txt")
    send_file file_path, disposition: 'inline'
  end
end
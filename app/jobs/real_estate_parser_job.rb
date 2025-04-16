class RealEstateParserJob < ApplicationJob
  queue_as :default

  def perform(real_estate_parser_id)
    parser = RealEstateParser.find_by(id: real_estate_parser_id)
    return if parser.blank? || !parser.is_active?

    latest_log = parser.real_estate_parser_logs.order(created_at: :desc).first
    return if latest_log.present? && latest_log.in_progress?

    parser.start
  end
end

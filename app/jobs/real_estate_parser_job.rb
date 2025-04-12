class RealEstateParserJob < ApplicationJob
  queue_as :default

  def perform(real_estate_parser_id)
    parser = RealEstateParser.find_by(id: real_estate_parser_id)
    return if parser.blank?
    parser.start
  end
end

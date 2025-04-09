class RealEstateParserJob < ApplicationJob
  queue_as :default

  def perform(id)
    parser = RealEstateParser.find_by(id: id)
    return if parser.blank?
    parser.start
  end
end
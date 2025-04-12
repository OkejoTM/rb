# == Schema Information
#
# Table name: real_estate_parsers
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agency_id  :bigint           indexed
#
class RealEstateParser < ApplicationRecord
  has_many :real_estate_parser_logs, dependent: :destroy

  belongs_to :agency, optional: true

  def status
    self.real_estate_parser_logs.last.present? ? self.real_estate_parser_logs.last.status : 'process_not_started'
  end

  def started_at
    real_estate_parser_logs.last&.created_at.presence
  end

  def finished_at
    real_estate_parser_logs.last&.finished_at.presence
  end

  def start
    Parsers::Vartur::Schema.new(Parser::AgentProxy.new, Parsers::RealEstateParserLogger.new("log/parsers", RealEstateParser.find_by(id: id))).call
  end

  def name
    "Real Estate Parser #{id}"
  end
end

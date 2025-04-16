# == Schema Information
#
# Table name: real_estate_parsers
#
#  id         :bigint           not null, primary key
#  is_active  :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agency_id  :bigint           indexed
#
class RealEstateParser < ApplicationRecord
  has_many :real_estate_parser_logs, dependent: :destroy

  belongs_to :agency, optional: true

  scope :active, -> { where(is_active: true) }

  def status
    return 'process_not_started' if real_estate_parser_logs.blank?
    real_estate_parser_logs.order(:created_at).last.status
  end

  def started_at
    real_estate_parser_logs.order(:created_at).last&.created_at.presence
  end

  def finished_at
    real_estate_parser_logs.order(:created_at).last&.finished_at.presence
  end

  def start
    return false unless is_active?
    "Parsers::#{agency.slug.camelize}::Schema".constantize.new(Parser::AgentProxy.new, Parsers::RealEstateParserLogger.new("log/parsers", self)).call
  end

  def name
    "Real Estate Parser #{id}"
  end
end

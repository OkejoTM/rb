# == Schema Information
#
# Table name: real_estate_parser_logs
#
#  id                       :bigint           not null, primary key
#  created_properties_count :integer
#  deleted_properties_count :integer
#  status                   :integer          default("unsuccess"), not null
#  updated_properties_count :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  real_estate_parser_id    :bigint           indexed
#
class RealEstateParserLog < ApplicationRecord
  belongs_to :real_estate_parser

  STATUSES = {
    unsuccess: 0,
    success: 1,
    in_progress: 2,
  }.freeze

  enum status: STATUSES

  def started_at
    created_at
  end

  def finished_at
    updated_at unless in_progress?
  end
end

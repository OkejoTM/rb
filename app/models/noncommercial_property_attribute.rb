# == Schema Information
#
# Table name: noncommercial_property_attributes
#
#  id             :bigint           not null, primary key
#  bathroom_count :integer
#  bedroom_count  :integer
#  level          :integer
#  level_count    :integer
#  property_id    :bigint           indexed
#

class NoncommercialPropertyAttribute < ApplicationRecord
  # belongs_to :noncommercial_property
  belongs_to :property
end

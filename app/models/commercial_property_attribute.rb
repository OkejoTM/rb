# == Schema Information
#
# Table name: commercial_property_attributes
#
#  id                          :bigint           not null, primary key
#  min_absolute_income         :integer
#  min_absolute_income_unit    :integer
#  min_amount_of_own_capital   :integer
#  rentable_area               :integer
#  rentable_area_unit          :integer
#  rental_yield_per_month      :integer
#  rental_yield_per_month_unit :integer
#  rental_yield_per_year       :integer
#  rental_yield_per_year_unit  :integer
#  property_id                 :bigint           indexed
#

class CommercialPropertyAttribute < ApplicationRecord
  belongs_to :property
end

# == Schema Information
#
# Table name: agency_bids
#
#  id            :bigint           not null, primary key
#  agency_name   :string           not null
#  bitrix_synced :integer          default("waiting"), not null
#  email         :string           not null
#  message       :string           not null
#  mobile        :boolean          default(FALSE)
#  name          :string           not null
#  phone         :string           not null
#  website       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bitrix_id     :integer
#  country_id    :bigint           indexed
#

class AgencyBid < ApplicationRecord
  include Commentable
  include ContactWayModule
  include Decoratable
  include BitrixSyncable

  belongs_to :country

  validates_with AgencyBidValidator
end

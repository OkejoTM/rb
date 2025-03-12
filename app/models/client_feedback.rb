# == Schema Information
#
# Table name: client_feedbacks
#
#  id            :bigint           not null, primary key
#  bitrix_synced :integer          default("waiting"), not null
#  message       :string
#  mobile        :boolean          default(FALSE)
#  name          :string
#  phone         :string
#  source        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bitrix_id     :integer
#

class ClientFeedback < ApplicationRecord
  include Commentable
  include ContactWayModule
  include Decoratable
  include BitrixSyncable

  validates_with ClientFeedbackValidator

  def has_source_page?
    source.present?
  end
end

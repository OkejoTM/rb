module BitrixSyncable
  extend ActiveSupport::Concern

  BITRIX_SYNC_STATES = {
      waiting: 0,
      success: 1,
      fail: 2,
  }.freeze

  included do
    enum bitrix_synced: BITRIX_SYNC_STATES, _prefix: true
  end
end

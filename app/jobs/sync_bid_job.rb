class SyncBidJob < ApplicationJob
  queue_as :default

  def perform(id, class_name)
    bid = class_name.safe_constantize.find(id)

    bid.with_lock do
      # Обновляем информацию на случай, если между блокировкой и загрузкой были изменения
      bid.reload

      # Выходим из блока, если лид в обработке или уже синхронизирован
      next if bid.bitrix_synced_success?

      bid.bitrix_synced_waiting!

      BidSynchronizer
        .new(bid)
        .call
    end
  end
end

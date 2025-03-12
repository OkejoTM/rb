class Admin::BitrixController < Admin::BasicAdminController

  # POST /bitrix/synchronize
  def synchronize
    bid_id = params[:bid_id]
    status = nil
    notice = nil

    bid_class = convert_class_type(params[:bid_type])
    bid = bid_class&.find_by(id: bid_id)

    if bid.present?
      bid.with_lock do
        bid.reload

        if bid.bitrix_synced_fail?
          bid.bitrix_synced_waiting!
          SyncBidJob.perform_later(bid_id, bid_class.to_s)
          status = :ok
          notice = t('bitrix.errors.queued')
        else
          status = :ok
          notice = t('bitrix.errors.already_in_queue')
        end

      end
    else
      notice = t('nothing_found')
      status = :bad_request
    end

    respond_to do |format|
      format.json do
        render json: { notice: notice },
               status: status
      end
    end
  end

  private

    def convert_class_type(type_params)
      case type_params
        when 'Bid'
          Bid
        when 'AgencyBid'
          AgencyBid
        when 'ClientFeedback'
          ClientFeedback
        else
          nil
      end
    end
end

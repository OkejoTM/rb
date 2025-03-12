class BidsController < ApplicationController
  include BidOperationFactory

  layout 'frontend'

  # POST /bids
  # POST /bids.json
  def create_bid
    respond_to do |format|

      @bid = bid_operation(
        email_template: :send_new_bid_message,
        bid_class: Bid,
        form_params: params.require(:bid),
        format: format,
        request: request
      )

    end
  end
end

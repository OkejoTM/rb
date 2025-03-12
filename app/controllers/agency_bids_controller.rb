class AgencyBidsController < ApplicationController
  include BidOperationFactory

  layout 'frontend'

  # GET /agency_bid
  def new_agency_bid
    add_breadcrumb t('common.main_page'), :root_path
    add_breadcrumb t('agency_bid.title'), ''

    @agency_bid = AgencyBid.new
    @countries = Country.order(:title_ru).select(:title_ru, :title_en, :id)
  end

  # POST /agency_bid.json
  def create_agency_bid
    respond_to do |format|

      @agency_bid = bid_operation(
        email_template: :send_new_agency_bid_message,
        bid_class: AgencyBid,
        form_params: params.require(:agency_bid),
        format: format,
        request: request
      )

    end
  end
end

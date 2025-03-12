class Admin::AgencyBidsController < Admin::BasicAdminController
  init_resource :agency_bid
  define_actions :index, :destroy

  private
    def index_hook
      @objects = @objects.order(created_at: :desc)

      add_breadcrumb t('agency_bids.index'), :agency_bids_path

      @page_title = t('agency_bids.index')
    end
end

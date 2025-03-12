class Admin::BidsController < Admin::BasicAdminController
  init_resource :bid
  define_actions :index, :update, :destroy

  private
    def index_hook
      if params[:agency_id].present?
        @objects = @objects.by_agency_id(params[:agency_id])
      end

      @objects = authorized_scope(@objects)

      @objects = Bid.filter(@objects, params)

      @objects = @objects
                     .joins(property: :agency)
                     .eager_load(:contact_ways, :comments, property: [:city, :location_types])
                     .order(created_at: :desc)

      if params[:country_id].present?
        @objects = @objects.where(properties: { country_id: params[:country_id] })
        @country = Country.find(params[:country_id])
      end

      if params[:property_supertype_id].present?
        @property_supertype = PropertySupertype.find(params[:property_supertype_id])
        @objects = @objects.where(properties: { property_type_id: @property_supertype.property_type_ids })
      end

      if %w[cheap medium expensive on_request].include?(params[:category])
        @objects = @objects.send(params[:category])
      end

      @countries = CountryQuery.countries_for_select

      add_breadcrumb t(:index, scope: :bids), :bids_path

      @page_title = t(:index, scope: :bids)

      # Получение обращений с комментариями для каждого обращения
      @bids_with_comments = @objects.map do |bid|
        comments = authorized_scope(bid.comments)
        { bid: bid, comments: comments }
      end

      @pagination = Pagination.new(@bids_with_comments, current_page: params[:page].to_i, page_size: 30)
      @agencies = AgencyQuery.agencies_for_select
    end
end

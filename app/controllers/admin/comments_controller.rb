class Admin::CommentsController < Admin::BasicAdminController
  init_resource :comment
  define_actions :destroy

  def index
    @objects = authorized_scope(Comment.includes(:created_by)
                                         .where(item_id: params[:commentable_id], item_type: params[:commentable_type])
                                         .order(:created_at))
  end

  def create
    @object = Comment.new(object_params)

    respond_to do |format|
      if @object.save
        notice = notification_success(t('bids.success_notice'))

        format.json do
          render 'admin/comments/create',
                 locals: {
                   notice: notice,
                   comment: @object
                 },
                 status: :created
        end
      else
        format.json do
          render json: { notice: t('common.error'), errors: @object.errors },
                 status: :unprocessable_entity
        end
      end
    end
  end
end

class Admin::ClientFeedbacksController < Admin::BasicAdminController
  init_resource :client_feedback
  define_actions :index, :destroy

  private
    def index_hook
      @objects = @objects.order(created_at: :desc)

      add_breadcrumb t(:index, scope: :client_feedbacks), :client_feedbacks_path

      @page_title = t(:index, scope: :client_feedbacks)
    end
end

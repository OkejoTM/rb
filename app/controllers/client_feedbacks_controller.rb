class ClientFeedbacksController < ApplicationController
  include BidOperationFactory

  layout 'frontend'

  # POST /client_feedback.json
  def create_client_feedback
    respond_to do |format|

      @client_feedback = bid_operation(
        email_template: :send_new_client_feedback_message,
        bid_class: ClientFeedback,
        form_params: params.require(:client_feedback),
        format: format,
        request: request
      )

    end
  end
end

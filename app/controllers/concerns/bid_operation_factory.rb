module BidOperationFactory

  # Производит операцию создания заявки
  # @param [Symbol] email_template
  # @param [Class] bid_class
  # @param [Hash] form_params
  # @param [ActionController::MimeResponds::Collector] format
  # @param [ActionDispatch::Request] request
  # @return [Bid|AgencyBid|ClientFeedback]
  def bid_operation(email_template:, bid_class:, form_params:, format:, request:)
    BidOperation
      .new
      .with_step_args(
        notify_by_email: [email_template: email_template],
        init: [class_name: bid_class]
      )
      .call(request: request, form_params: form_params) do |m|

        m.success do |bid|
          notice = notification_success(t('bids.success_notice', name: bid.name))

          format.json do
            render json: { notice: notice },
                   status: :created
          end

          bid
        end

        m.failure do |bid|

          format.json do
            render json: { errors: bid.errors },
                   status: :unprocessable_entity
          end

          bid
        end
      end
  end
end

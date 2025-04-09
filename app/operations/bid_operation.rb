class BidOperation
  include Dry::Transaction
  include UserEmailNotifier

  map :check_user_device
  map :init
  step :save
  # tee :notify_by_email
  # tee :sync_bid

  def check_user_device(request:, form_params:)
    browser = Browser.new(request.user_agent)

    form_params.tap do |h|
      h[:mobile] = browser.device.mobile? || false
    end
  end

  def init(form_params, class_name:)
    permitted_params = permit_params(class_name: class_name, form_params: form_params)

    class_name.new(permitted_params)
  end

  def save(bid)
    if bid.save
      Success(bid)
    else
      Failure(bid)
    end
  end

  def notify_by_email(bid, email_template:)
    notify_subscribed_users_with(email_template, bid)
  end

  def sync_bid(bid)
    return unless Rails.env.production?
    SyncBidJob.perform_later(bid.id, bid.class.to_s)
  end

  private

    def permit_params(class_name:, form_params:)
      permitted = class_name.attribute_names.deep_dup
      permitted.push(contact_ways_attributes: %i[way_type])

      form_params.permit(permitted)
    end
end

module UserEmailNotifier
  extend ActiveSupport::Concern

  def notify_subscribed_users_with(email_template, *args)
    subscribed_users = User.subscribed

    agency_id = args.first.respond_to?(:property) ? args.first.property.agency_id : nil
    subscribed_agents = subscribed_users.agent.where(agency_id: agency_id)

    subscribed_admins = subscribed_users.admin

    subscribed_users_to_notify = subscribed_agents.or(subscribed_admins)

    subscribed_users_to_notify.each do |user|
      UserMailer.send(email_template, user, *args).deliver_now
    end
  end
end

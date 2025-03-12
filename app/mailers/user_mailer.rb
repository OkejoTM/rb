class UserMailer < ApplicationMailer
  helper :properties

  def send_new_user_message(user)
    @user = user
    @url  = "https://#{Rails.application.default_url_options[:host]}/users/sign_in"
    mail(to: @user.email, subject: t(:welcome, scope: :devise)) do |format|
      format.html
    end
  end

  def send_new_bid_message(user, bid)
    @bid = bid
    subject = "Propimo | Новое обращение #{@bid.id}"
    mail(to: user.email, subject: subject) do |format|
      format.html
    end
  end

  def send_new_agency_bid_message(user, agency_feedback)
    @agency_feedback = agency_feedback
    subject = "Propimo | Заявка от агентства #{@agency_feedback.id}"
    mail(to: user.email, subject: subject) do |format|
      format.html
    end
  end

  def send_new_client_feedback_message(user, client_feedback)
    @client_feedback = client_feedback
    subject = "Propimo | Отзыв от клиента #{@client_feedback.id}"
    mail(to: user.email, subject: subject) do |format|
      format.html
    end
  end
end

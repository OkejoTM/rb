# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string           indexed
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null, indexed
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  original_role          :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           indexed
#  role                   :integer          default("admin")
#  sign_in_count          :integer          default(0), not null
#  subscribed             :boolean          default(FALSE)
#  timezone               :string           default("GMT")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  agency_id              :bigint           indexed
#

class User < ApplicationRecord
  include SimulationRole
  include Filterable
  include QueryModule

  query_fields :email

  filter_params :query, :by_role

  EMAIL_REGEX = /\A[A-Za-z0-9](([_\\.\\-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([\\.\\-]?[a-zA-Z0-9]+)*)\.([A-Za-z]{2,})\z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  ROLES = {
    admin: 0,
    content_manager: 1,
    agent: 2,
    seller_person: 3,
  }.freeze

  enum role: ROLES

  belongs_to :agency, optional: true

  # Подписанные на рассылку писем
  scope :subscribed, -> { where(subscribed: true) }

  scope :by_role, ->(role) { where(role: role) }

  validates :email, presence: { message: 'Email должен быть указан!' },
            uniqueness: { message: 'Такой пользователь уже существует!' },
            format: { with: EMAIL_REGEX }

  validates :agency_id, presence: { message: 'Агентство должно быть указано!' }, if: :agent?

  after_create :send_email_notification

  # Отправка письма с логином и паролем для нового пользователя
  def send_email_notification
    if self.persisted?
      UserMailer.send_new_user_message(self).deliver
    end
  end

  cattr_accessor :current_user

  # Генерация пароля для учетной записи пользователя
  # @return [String] сгенерированный пароль
  # @example
  #   User.find(1).generate_password
  def generate_password
    chars_in_pass = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a + %w(_ -)
    generated_pass = chars_in_pass.sort_by { rand }.join[0...8]

    self.password = generated_pass
    self.password_confirmation = generated_pass
  end
end

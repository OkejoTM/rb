# == Schema Information
#
# Table name: messenger_types
#
#  id         :bigint           not null, primary key
#  title      :string
#  icon_class :string           default(""), not null
#

class MessengerType < ApplicationRecord
  has_many :messengers, dependent: :nullify

  validates :title, presence: { message: 'Заголовок должен быть указан!' },
            uniqueness: { message: 'Такой тип мессенджера уже существует!' }
end

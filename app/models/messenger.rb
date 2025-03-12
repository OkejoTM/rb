# == Schema Information
#
# Table name: messengers
#
#  id                :bigint           not null, primary key
#  phone             :string
#  agency_id         :bigint           not null, indexed
#  messenger_type_id :bigint           not null, indexed
#

class Messenger < ApplicationRecord
  belongs_to :agency
  belongs_to :messenger_type

  validates :messenger_type_id, presence: true
  validates :phone, length: { minimum: 3, message: "должно быть больше 3" }, presence: true

  delegate :title, :icon_class, to: :messenger_type
end

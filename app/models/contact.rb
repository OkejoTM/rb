# == Schema Information
#
# Table name: contacts
#
#  id               :bigint           not null, primary key
#  contactable_type :string           indexed => [contactable_id]
#  value            :string
#  contact_type_id  :integer          not null, indexed
#  contactable_id   :integer          indexed => [contactable_type]
#

class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true, optional: true
  belongs_to :contact_type

  validates :contact_type_id, presence: true
  validates :value, length: { minimum: 3, message: "должно быть больше 3" }, presence: true

  delegate :title, :icon_class, to: :contact_type

  # Возвращает название в зависимости от языка
  # @param params [Hash] параметры для создания контакта
  # @example
  #   Contact.first.build_contact
  def build_contact(params)
    self.contact = contact_type.constantize.new(params)
  end
end

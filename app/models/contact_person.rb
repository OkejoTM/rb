# == Schema Information
#
# Table name: contact_people
#
#  id        :bigint           not null, primary key
#  name_en   :string
#  name_ru   :string
#  role_en   :string
#  role_ru   :string
#  agency_id :bigint           indexed
#

class ContactPerson < ApplicationRecord
  include Localizable

  translate_fields :name, :role
  belongs_to :agency
  has_many :contacts, as: :contactable, dependent: :destroy, index_errors: true
  has_one :avatar, as: :imageable, class_name: "Picture", dependent: :destroy

  accepts_nested_attributes_for :avatar, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: proc { |attributes| attributes['value'].blank? }

  validates_associated :contacts
  # validates :name_ru, :name_en, presence: true

  # def avatar
  #   super || build_avatar(width: 200)
  # end

  # TODO вынести в презентер
  # def name_en
  #   if self.persisted?
  #     super.presence || I18n.t(:no_name, scope: :common)
  #   end
  # end

  # def name_ru
  #   if self.persisted?
  #     super.presence || name_en
  #   end
  # end
end

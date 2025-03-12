# == Schema Information
#
# Table name: contact_ways
#
#  id                   :bigint           not null, primary key
#  contact_wayable_type :string           indexed => [contact_wayable_id]
#  way_type             :integer          default("whatsapp"), not null
#  contact_wayable_id   :bigint           indexed => [contact_wayable_type]
#

class ContactWay < ApplicationRecord

  CONTACT_WAYS = {
      whatsapp: 0,
      viber: 1,
      telegram: 2,
  }.freeze
  enum way_type: CONTACT_WAYS, _suffix: true

  belongs_to :contact_wayable, polymorphic: true
end

# == Schema Information
#
# Table name: agency_other_contacts
#
#  id         :bigint           not null, primary key
#  content_en :text
#  content_ru :text
#  title_en   :string
#  title_ru   :string
#  agency_id  :bigint           indexed
#

class AgencyOtherContact < ApplicationRecord
  include Titleable

  attr_accessor :title, :content

  belongs_to :agency

  serialize :content_ru, Array
  serialize :content_en, Array
end

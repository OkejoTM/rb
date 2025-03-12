# == Schema Information
#
# Table name: property_tag_aliases
#
#  id              :bigint           not null, primary key
#  name            :string           not null, indexed
#  property_tag_id :bigint           not null, indexed
#

class PropertyTagAlias < ApplicationRecord
  belongs_to :property_tag

  validates :name,
            presence: { message: 'Имя синонима должно существовать!' },
            uniqueness: { message: 'Такой синоним тега уже существует!' }
end

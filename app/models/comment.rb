# == Schema Information
#
# Table name: comments
#
#  id            :bigint           not null, primary key
#  item_type     :string           not null, indexed => [item_id]
#  message       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           indexed
#  item_id       :bigint           not null, indexed => [item_type]
#

class Comment < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :item, polymorphic: true

  validates_with CommentValidator

  def author_name
    created_by&.email || ""
  end
end

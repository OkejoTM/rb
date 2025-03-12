module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :item, dependent: :destroy
  end

  # Метод получения последнего комментария.
  def last_comment(user)
    last_comment = comments.by_role(user).last
    last_comment ? last_comment.message : ''
  end

  def last_commentator
    comments.last.created_by unless comments.empty?
  end
end

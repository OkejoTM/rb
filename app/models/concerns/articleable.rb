module Articleable
  extend ActiveSupport::Concern

  included do
    has_many :articles, dependent: :nullify
  end

  def visible_articles(locale)
    articles.visible(locale)
  end

  def has_visible_articles?(locale)
    visible_articles(locale).exists?
  end
end

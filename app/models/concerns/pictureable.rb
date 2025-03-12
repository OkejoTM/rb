module Pictureable
  extend ActiveSupport::Concern

  included do
    has_many :pictures, -> { order(:priority) }, as: :imageable, dependent: :destroy
    accepts_nested_attributes_for :pictures, allow_destroy: true
  end
end

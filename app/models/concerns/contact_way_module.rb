module ContactWayModule
  extend ActiveSupport::Concern

  included do
    has_many :contact_ways, as: :contact_wayable, dependent: :destroy
    accepts_nested_attributes_for :contact_ways, allow_destroy: true
  end
end

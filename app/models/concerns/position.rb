module Position
  extend ActiveSupport::Concern
  included do
    scope :in_area, ->(latNE, lngNE, latSW, lngSW) { where("latitude < ? AND longitude < ? AND latitude > ? AND longitude > ?", latNE, lngNE, latSW, lngSW) }
    scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
  end
end

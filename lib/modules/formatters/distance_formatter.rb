module Formatters::DistanceFormatter

  #@!group Единицы измерения длины
  # м, meters
  DISTANCE_UNIT_METERS = 0
  # км, kilometers
  DISTANCE_UNIT_KILOMETERS = 1
  # миль, miles
  DISTANCE_UNIT_MILES = 2
  #@!endgroup

  class << self
    def format_distance(distance, distance_unit)
      return "#{distance.ceil} #{format_distance_unit(distance_unit)}" if distance.present? && distance_unit.present?
      ""
    end

    def distance_units
      {
          DISTANCE_UNIT_METERS => I18n.t("distances.meters"),
          DISTANCE_UNIT_KILOMETERS => I18n.t("distances.kilometers"),
          DISTANCE_UNIT_MILES => I18n.t("distances.miles")
      }
    end

    def format_distance_unit(distance_unit)
      distance_units.fetch(distance_unit, "")
    end
  end
end

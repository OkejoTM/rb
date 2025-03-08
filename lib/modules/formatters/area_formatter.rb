module Formatters::AreaFormatter

  #@!group Единицы измерения площади
  # sq. m, кв. м
  AREA_UNIT_SQ_M = 0
  # ares, ары, сот.
  AREA_UNIT_ARES = 1
  # hectares, Га
  AREA_UNIT_HECTARES = 2
  # ares, акры
  AREA_UNIT_ACRES = 3
  # sq. ft, кв. фт
  AREA_UNIT_SQ_FT = 4
  #@!endgroup

  class << self
    def format_area(area, area_unit)
      return "#{area.ceil} #{format_area_unit(area_unit)}" if area.present? && area > 0 && area_unit.present?
      ""
    end

    def area_units
      {
          AREA_UNIT_SQ_M => I18n.t("squares.sq_m"),
          AREA_UNIT_ARES => I18n.t("squares.ares"),
          AREA_UNIT_HECTARES => I18n.t("squares.hectares"),
          AREA_UNIT_ACRES => I18n.t("squares.acres"),
          AREA_UNIT_SQ_FT => I18n.t("squares.sq_ft"),
      }
    end

    def format_area_unit(square_unit)
      area_units.fetch(square_unit, "")
    end
  end
end

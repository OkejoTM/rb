class LocationFilterOptions
  class << self
    def sort_options
      {
          I18n.t(:russian_title, scope: :sort) => "title_ru",
          I18n.t(:english_title, scope: :sort) => "title_en",
          I18n.t(:properties_count_desc, scope: :sort) => "properties_count DESC",
          I18n.t(:properties_count, scope: :sort) => "properties_count"
      }
    end

    def continents
      {
          I18n.t(:eu, scope: :continent) => "EU",
          I18n.t(:as, scope: :continent) => "AS",
          I18n.t(:oc, scope: :continent) => "OC",
          I18n.t(:an, scope: :continent) => "AN",
          I18n.t(:af, scope: :continent) => "AF",
          I18n.t(:na, scope: :continent) => "NA",
          I18n.t(:sa, scope: :continent) => "SA"
      }
    end
  end
end

class CountryQuery
  class << self
    def group_by_continent
      Country.visible
          .order(active_and_moderated_properties_count: :desc)
          .group_by(&:continent)
          .each { |_, v| v.sort_by! { |c| c.title } }
    end

    def order_by_popular_and_properties
      Country.visible.order(is_popular: :desc, active_and_moderated_properties_count: :desc)
    end

    def countries_for_select(continent: nil)
      countries =
          if continent.present?
            Country.continent(continent)
          else
            Country.all
          end

      countries.select(:id, :title_ru, :continent).order(title_ru: :asc)
             .pluck(:title_ru, :id, :continent)
             .map { |c| [c[0], c[1], { continent: c[2] }] }
    end
  end
end

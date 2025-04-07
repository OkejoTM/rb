class Parsers::Vartur::Operations::City::VarturSearch < Parsers::Operation::City::Search
  private

    def find_by_title(attributes, locales)
      conditions = []
      params = {}

      locales.each do |locale|
        city_name = attributes[:"city_#{locale}"]
        next if city_name.blank?

        conditions << "title_#{locale} ILIKE :title_#{locale}"
        params[:"title_#{locale}"] = city_name
      end

      return nil if conditions.empty?

      City.where(region_id: attributes[:region_id])
          .where(conditions.join(' OR '), params)
          .first
    end
end

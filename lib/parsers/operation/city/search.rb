class Parsers::Operation::City::Search
  attr_reader :result

  def initialize(attributes, locales)
    @attributes = attributes
    @locales = locales
    @result = nil
  end

  def call
    @result = find_by_title(@attributes, @locales) || find_by_alternate_name(@attributes)
    !@result.nil?
  end

  private

    def find_by_title(attributes, locales)
      conditions = []
      params = { region_id: attributes[:region_id] }

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

    def find_by_alternate_name(attributes)
      city_name = attributes[:city_en]
      region_id = attributes[:region_id]

      city_alternates = AlternateName.where("lower(alternate_name) = lower(?)", city_name)
      matching_city_ids = city_alternates.pluck(:geoname_id)

      cities = City.where(id: matching_city_ids)
      cities = cities.where(region_id: region_id) if region_id.present?

      cities.first
    end
end

class Parsers::Operation::Region::Search
  attr_reader :result

  def initialize(attributes, locales)
    @attributes = attributes
    @locales = locales
    @result = nil
  end

  def call
    @result = find_by_title(@attributes, @locales) || find_by_alternate_name(@attributes)
    @result.present?
  end

  private

    def find_by_title(attributes, locales)
      conditions = []
      params = { country_id: attributes[:country_id] }

      locales.each do |locale|
        region_name = attributes[:"region_#{locale}"]
        next if region_name.blank?

        conditions << "title_#{locale} ILIKE :title_#{locale}"
        params[:"title_#{locale}"] = region_name
      end

      return nil if conditions.empty?

      Region.where(country_id: attributes[:country_id])
            .where(conditions.join(' OR '), params)
            .first
    end

    def find_by_alternate_name(attributes)
      region_name = attributes[:region_en]
      country_id = attributes[:country_id]

      region_alternates = AlternateName.where("lower(alternate_name) = lower(?)", region_name)
      matching_region_ids = region_alternates.pluck(:geoname_id)
      regions = Region.where(id: matching_region_ids)

      regions = regions.where(country_id: country_id) if country_id.present?
      regions.first
    end
end

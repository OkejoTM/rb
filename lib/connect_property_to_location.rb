class ConnectPropertyToLocation
  class << self
    #Привязывает недвижимость в странах
    def connect_property_by_country_ids(country_ids)
      properties = Property.where('longitude > 0 AND latitude > 0 AND city_id IS NULL AND country_id IN (?)', country_ids)
      prop_count = properties.count
      results = {}
      properties.each_with_index do |property, index|
        Rails.logger.debug { "--- Add cities #{index + 1} of #{prop_count} in #{Time.now.to_s}" } if index % (prop_count / 15) == 0
        if property.region.present?
          find_city_by_coordinates(property, results)
        elsif property.country.present?
          connect_property_without_region(property, results)
        end
      end
    end

    def connect_property_without_location()
      properties = Property.where('longitude > 0 AND latitude > 0 AND country_id IS NULL')
      prop_count = properties.count
      results = {}
      properties.each_with_index do |property, index|
        Rails.logger.debug { "--- Add cities #{index + 1} of #{prop_count} in #{Time.now.to_s}" } if index % 10 == 0
        connect_property_without_country(property, results);
      end
    end

    private
      #Привязывает 1 недвижимость без страны к локации
      def connect_property_without_country(property, results)
        property.country = LocationDistance.find_nearest(property, Country.all)
        if property.country.present?
          connect_property_without_region(property, results)
        end
        property.save
      end

      #Привязывает 1 недвижимость без региона к локации
      def connect_property_without_region (property, results)
        property.region = LocationDistance.find_nearest(property, property.country.regions)
        if (property.region.present?)
          find_city_by_coordinates(property, results)
        end
        property.save
      end

      #Привязывает 1 недвижимость к городу по координатам
      def find_city_by_coordinates (property, results)
        if results.has_value?([LocationDistance.round_off(property.latitude), LocationDistance.round_off(property.longitude)])
          property.city_id = results.key([LocationDistance.round_off(property.latitude), LocationDistance.round_off(property.longitude)])
          property.save
        else
          property.city_id = LocationDistance.find_nearest(property, property.region.cities)&.id
          results[property.city_id] = [LocationDistance.round_off(property.latitude), LocationDistance.round_off(property.longitude)]
          property.save
        end
      end
  end
end

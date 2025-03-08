class LocationDistance
  class << self
    #Находит близкую локацию из массива
    def find_nearest(property, array_location)
      results = {}
      array_location.each do |arr_c|
        #111km = 1 градус по широте
        if results.keys.exclude?(arr_c) && arr_c.longitude > 0 && arr_c.latitude > 0
          dist = distance(arr_c, property)
          if results.values.blank? || results.values.min > dist
            results[arr_c] = dist
          end
        end
      end
      results.key(results.values.min)
    end

    #Проверяет находится ли локация в данном радиусе
    def nearly?(location, other_location, radius)
      location.longitude.nil? || location.latitude.nil? ||
          other_location.longitude.nil? || other_location.latitude.nil? || distance(location, property) <= radius
    end

    #Подсчитывает расстояние
    def distance (location, other_location)
      Math.sqrt((other_location.longitude - location.longitude)**2 + (other_location.latitude - location.latitude)**2)
    end

    def distence_in_km(location, other_location)
      round_off(distance(location, other_location) * RATIO_KM_GRAD)
    end

    private

      RATIO_KM_GRAD = 111.11

      #Округляет число до 3-ех знаков после запятой
      def round_off(number, order = 1000)
        (number * order).to_i.to_f / order
      end

  end
end

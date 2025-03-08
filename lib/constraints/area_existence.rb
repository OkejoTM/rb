module Constraints
  class AreaExistence
    def matches?(request)
      if request.path_parameters[:country_url].present?
        return false unless request.path_parameters[:country_url].match(/[a-z0-9\-_].+/)

        # country = Country.active.find_by(slug: request.path_parameters[:country_url])
        # return false unless country
      end

      if request.path_parameters[:city_url].present?
        return false unless request.path_parameters[:city_url].match(/[a-z0-9\-_].+/)

        # city = City.active.find_by(slug: request.path_parameters[:city_url])
        # return false unless city
      end

      if request.path_parameters[:region_url].present?
        return false unless request.path_parameters[:region_url].match(/[a-z0-9\-_].+/)

        # region = Region.active.find_by(slug: request.path_parameters[:region_url])
        # return false unless region
      end

      true
    end
  end
end

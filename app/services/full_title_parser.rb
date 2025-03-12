# module Services
class FullTitleParser

  DEFAULT_SEARCH_URL = UrlsHelper.residential_path

  attr_reader :city, :region, :country

  def initialize
    @city = nil
    @region = nil
    @country = nil
  end

  #Возвращает путь для запроса поиска локации
  def get_location_path(query)
    if query.present?
      parse_full_title(query)
      # Пользователь выбрал из перечня
      area = @city || @region || @country
      if area.present?
        return area.seo_path
      else
        # Пользователь ввел свое
        result = SearchLocations.new(query).perform
        links = result["links"]
        # Пользователь ввел запрос, по которому есть результаты
        if links.present?
          first_location = (result["Countries"] + result["Regions"] + result["Cities"]).first
          if first_location.present?
            return links[first_location]
          end
        end
      end
    end

    # Пользователь ничего не ввел
    DEFAULT_SEARCH_URL
  end

  #Парсит полное название для локации
  def parse_full_title(query)
    locations = query.split(/, /)
    country_title = locations.last
    region_title = locations.second_to_last
    city_title = locations.third_to_last
    if country_title.present?
      @country = find_location_by_title(Country, country_title);
    end
    if region_title.present? && @country.present?
      if @country.regions.present?
        @region = find_location_by_title(@country.regions, region_title)
      else
        @city = find_location_by_title(@country.cities, region_title)
      end
    end
    if city_title.present? && @city.blank? && @region.present?
      @city = find_location_by_title(@region.cities, city_title)
    end
  end

  private
    def find_location_by_title(locations, title)
      if I18n.locale == :ru
        locations.find_by(title_ru: title)
      else
        locations.find_by(title_en: title)
      end
    end
end
# end

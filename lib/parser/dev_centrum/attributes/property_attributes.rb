# Информация по магическим числам:
# http://prian.ru/files/xml/tech_treb.txt
# http://prian.ru/files/xml/properties.xml
class Parser::DevCentrum::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  def unique_id
    id = take_last_element_text('id')
    "dev_centrum_#{id}"
  end

  def description
    take_last_element_text('description')
  end

  def h1
    take_last_element_text('specialtxt')
  end

  def studio
    type == 'студия'
  end

  def type
    type_id = take_last_element_text('object_id')
    type_hash.fetch(type_id.to_sym)
  end

  def type_hash
    {
      # Квартира:
      '1': 'квартира',
      '2': 'апартаменты',
      '11': 'таунхаус',
      '14': 'пентхаус',
      '20': 'мезонет',
      '21': 'студия',
      '22': 'лофт',
      # Коммерческая недвижимость:
      '5': 'кафе, ресторан',
      '6': 'магазин',
      '7': 'офис',
      '8': 'производство',
      '12': 'отель, гостиница',
      '13': 'иная коммерческая недвижимость',
      '18': 'доходный дом',
      '34': 'инвестиционный проект',
      # Земля:
      '10': 'земельный участок',
      '19': 'частный остров',
      # Дом:
      '3': 'дом',
      '24': 'коттедж',
      '25': 'вилла',
      '26': 'шале',
      '27': 'бунгало',
      '28': 'поместье',
      '29': 'замок',
      '30': 'ферма',
      '32': 'особняк',
      '33': 'дом под реконструкцию',
    }
  end

  def latitude
    take_last_element_text('latitude')&.to_f
  end

  def longitude
    take_last_element_text('longitude')&.to_f
  end

  def price
    return if price_on_request?

    take_last_element_text('price')&.to_f
  end

  def price_unit
    currency_id = take_last_element_text('currency_id')
    price_prian_hash.fetch(currency_id.to_sym)
  end

  def price_prian_hash
    {
      '1': 'USD',
      '2': 'EUR',
      '3': 'RUB',
    }
  end

  # not_show_price Цена по запросу/Не показывать цену на сайте (на детальной странице, в результатах поиска).
  # Числовое (0/1).
  # 1 Не показывать
  # Сама цена всё равно остаётся обязательным полем.
  def price_on_request?
    value = take_last_element_text('not_show_price')
    return false if value.blank?

    value == '1'
  end

  def rent_price_per_day
    take_last_element_text('price_day')
  end

  def rent_price_per_week
    take_last_element_text('price_week')
  end

  def rent_price_per_month
    take_last_element_text('price_month')
  end

  def country
    return @country_name if @country_name.present?

    country_id = take_last_element_text('country_id')
    @country_name = Parser::DevCentrum::Pages::CountryParser.new.call(country_id)
  end

  def district
    return @district_name if @district_name.present?

    str_variant = take_last_element_text('district')
    return str_variant if str_variant.present?

    district_id = take_last_element_text('district_id')
    @district_name = Parser::DevCentrum::Pages::DistrictParser.new.call(district_id)
  end

  # 1 Продажа
  # 2 Аренда
  def for_sale
    val = take_last_element_text('type_id')
    val == '1'
  end

  def building_year
    year = take_last_element_text('building_date')
    return if year.blank? || year.to_i.zero?

    Parser::ParserUtils.only_year_format(year.to_s)
  end

  def room_count
    take_last_element_text('rooms')&.to_i
  end

  def bedroom_count
    take_last_element_text('bedrooms')&.to_i
  end

  def bathroom_count
    take_last_element_text('bathrooms')&.to_i
  end

  def area
    take_last_element_text('square')
  end

  def area_unit
    'м2'
  end

  def plot_area
    area = take_last_element_text('square_land')
    return if area == '0'
    area
  end

  def plot_area_unit
    return if plot_area.blank?

    unit = take_last_element_text('square_land_unit')
    area_unit_hash.fetch(unit.to_sym)
  end

  def area_unit_hash
    {
      '128': Formatters::AreaFormatter::AREA_UNIT_ARES,
      '129': Formatters::AreaFormatter::AREA_UNIT_SQ_M,
      '130': Formatters::AreaFormatter::AREA_UNIT_HECTARES,
      '131': Formatters::AreaFormatter::AREA_UNIT_ACRES,
    }
  end

  def agency_link
    'http://www.czech-estate.cz'
  end

  def imgs
    response.css('image > filename').map do |node|
      { src: node.text }
    end
  end

  def level
    take_last_element_text('floor')
  end

  def level_count
    take_last_element_text('total_floor')
  end

  def construction_phase
    phase_id = take_last_element_text('building_type')
    return if phase_id.blank?

    construction_phase_hash.fetch(phase_id.to_sym)
  end

  def construction_phase_hash
    {
      '117': Property::CONSTRUCTION_PHASE_NEW,
      '118': Property::CONSTRUCTION_PHASE_OFF_PLAN,
      '119': Property::CONSTRUCTION_PHASE_RESALE,
    }
  end

  def language
    language_id = take_last_element_text('language_id')

    languages_hash.fetch(language_id.to_sym)
  end

  def languages_hash
    {
      '1': :ru,
      '3': :en,
    }
  end

  def to_airport
    significant_object_value(13)
  end

  def to_airport_unit
    significant_object_unit(13)
  end

  def to_railroad_station
    significant_object_value(14)
  end

  def to_railroad_station_unit
    significant_object_unit(14)
  end

  def to_beach
    significant_object_value(15)
  end

  def to_beach_unit
    significant_object_unit(15)
  end

  def to_historical_city_center
    significant_object_value(16)
  end

  def to_historical_city_center_unit
    significant_object_unit(16)
  end

  def to_nearest_big_city
    significant_object_value(17)
  end

  def to_nearest_big_city_unit
    significant_object_value(17)
  end

  def to_metro_station
    significant_object_value(18)
  end

  def to_metro_station_unit
    significant_object_unit(18)
  end

  def to_state_border
    significant_object_value(19)
  end

  def to_state_border_unit
    significant_object_unit(19)
  end

  def to_food_stores
    significant_object_value(20)
  end

  def to_food_stores_unit
    significant_object_unit(20)
  end

  def to_medical_facilities
    significant_object_value(21)
  end

  def to_medical_facilities_unit
    significant_object_unit(21)
  end

  def is_active
    # считаем, что все недвижимости в файле являются активными
    true
  end

  private

    def props_list_block
      take_last_element('properties')
    end

    # http://prian.ru/files/xml/properties.xml
    def find_property_with_id(id)
      props_block = props_list_block
      return [] if props_block.blank?

      props_block.filter do |node|
        prop_id = node.at('property_id').text
        prop_id.to_s == id.to_s
      end.map do |node|
        {
          id: node.at('property_id').text,
          value: node.at('property_value_enum').text,
          unit: node.at('property_value_unit')&.text,
        }
      end
    end

    def distance_to_significant_objects(object_type)
      find_property_with_id(12).find { |prop| prop[:value] == object_type }
    end

    def significant_object_value(object_type)
      prop = distance_to_significant_objects(object_type)
      return if prop.blank?

      prop.fetch(:value, nil)
    end

    def significant_object_unit(object_type)
      prop = distance_to_significant_objects(object_type)
      return if prop.blank?

      unit = prop.fetch(:unit, nil)
      distance_unit_hash.fetch(unit, nil)
    end

    def distance_unit_hash
      {
        '147': Formatters::DistanceFormatter::DISTANCE_UNIT_METERS,
        '148': Formatters::DistanceFormatter::DISTANCE_UNIT_KILOMETERS,
        '151': Formatters::DistanceFormatter::DISTANCE_UNIT_MILES,
      }
    end
end

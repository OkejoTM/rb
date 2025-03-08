class Parser::PortugalEstate::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  def external_link
    reference_id = take_last_element_text('Reference')
    "portugal_estate_id_#{reference_id}"
  end

  # Apartment
  # Bakery / Cakery
  # Bar / Restaurant
  # Detached House
  # Farm
  # Hostel
  # House
  # Land
  # Penthouse
  # Residential Plot
  # Restaurant
  # Semi-Detached House
  # Shop
  # Urban Land
  # Villa
  def property_type
    type = take_last_element_text('Propertytype')
    type.split('/').first.strip
  end

  # Available
  # Potential
  # Sold
  # Withdrawn
  def available?
    status = take_last_element_text('Availability')

    status.in? %w[Available Potential]
  end

  # New
  # Not Applicable
  # Under construction
  # Used
  def construction_phase
    status = take_last_element_text('Status')
    {
      'New': Property::CONSTRUCTION_PHASE_NEW,
      'Under construction': Property::CONSTRUCTION_PHASE_OFF_PLAN,
      'Used': Property::CONSTRUCTION_PHASE_RESALE,
    }.fetch(status, nil)
  end

  # <NetArea>424 m²</NetArea>
  # <Netarea>424</Netarea>
  def area
    area_field('Netarea', 'NetArea')
  end

  # <LandArea>424 m²</LandArea>
  # <Landarea>424</Landarea>
  def plot_area
    area_field('Landarea', 'LandArea')
  end

  def default_unit
    Formatters::AreaFormatter::AREA_UNIT_SQ_M
  end

  # <Constructionyear>01/01/2006</Constructionyear>
  def building_year
    year = take_last_element_text('Constructionyear')

    return if year.blank?

    Date::strptime(year.to_s, '%d/%m/%Y')
  end

  def level
    positive_int_field('Floor')
  end

  def level_count
    positive_int_field('Numberoffloors')
  end

  def price
    take_last_element_text('Forsale').to_i
  end

  def price_unit
    'EUR'
  end

  def country
    take_last_element_text('Country')
  end

  def region
    take_last_element_text('District')
  end

  def city
    city = take_last_element_text('Town')
    return if city.blank?

    normalize_encoding(city)
  end

  def description_ru
    take_last_element_text('Description_ru-ru')
  end

  def description_en
    take_last_element_text('Description_en-gb')
  end

  def bathroom_count
    positive_int_field('Bathrooms')
  end

  def bedroom_count
    positive_int_field('Bedrooms')
  end

  def price_on_request?
    price.blank?
  end

  # Добавлено для обратной совместимости с Operation#find_region Operation#find_city
  def rest_address
    "#{region.to_s} #{city.to_s}"
  end

  def for_sale
    true
  end

  def room_count
    positive_int_field('LivingRooms')
  end

  def agency_link
    'https://www.portugalestate.ru/'
  end

  def imgs
    take_last_element_text('ImageLink')
      &.split(',')
      &.map do |link|
        { src: link }
      end
  end

  def is_active
    available? # некоторые недвижимости в файле отмечены как проданы. Ставим их активность по статусу
  end

  private

    # поля площадей имеют два типа полей с одинаковой информацией
    # имена полей см. в методах площадей
    def area_field(field_name, fallback_field)
      area = take_last_element_text(field_name)

      area = take_last_element_text(fallback_field) if area.blank?

      Parser::ParserUtils.remove_non_numbers(area)&.to_i # 424 m² => 424
    end

    # Возвращает только позитивные целые числа из поля +field+
    def positive_int_field(field)
      floors = take_last_element_text(field)&.to_i
      return if floors.blank? || floors == 0

      floors
    end

    # Позволяет избавиться от умляутов и ударений (спец. символов utf8) без потерь самих символов
    # schön => schon
    def normalize_encoding(utf8_string)
      utf8_string
        .unicode_normalize(:nfkd) # Разбиваем спец. буквы на оригинальную букву и модификатор
        .encode('ascii', replace: '') # конвертит в ascii с избавлением модификаторов из utf8
    end
end

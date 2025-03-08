class Parser::Prian::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  # examples: https://prian.ru/price/latvia-21296-3056587.html
  # https://prian.ru/price/bulgaria-13835-3092935.html
  # https://prian.ru/price/georgia-14420-3043986.html
  # https://prian.ru/price/bahamas-17561-2995006.html #price_on_request
  # https://prian.ru/price/1370461.html
  # https://prian.ru/price/belgium-12136-425706.html
  # https://prian.ru/price/belgium-17561-2980857.html

  # локали, которые поддерживает сайт Prian.ru
  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      ru: {
        address: 'Адрес',
        location: 'Расположение',
        in: 'в',
        at: 'на',
        price_per_day: 'Цена за день',
        price_per_week: 'Цена за неделю',
        price_per_month: 'Цена за месяц',
        to_beach: 'До пляжа',
        to_airport: 'До аэропорта',
        to_railroad_station: 'До вокзала',
        to_food_stores: 'До продовольственных магазинов',
        to_historical_city_center: 'До исторического центра города',
        to_nearest_big_city: 'До ближайшего крупного населенного пункта',
        to_medical_facilities: 'До медучреждений',
        to_ski_lift: 'До горнолыжного подъемника',
        to_metro_station: 'До метро',
        to_state_border: 'До границы',
        room_count: 'Всего комнат',
        site_plot: 'Площадь участка',
        house_area: 'Площадь дома',
        floor_area: 'Площадь',
        date_of_construction: 'год постройки',
        completion_deadline: 'срок сдачи',
        repair: 'ремонт',
        price_on_request: 'Цена по запросу',
        studio: 'Студия',
        new_building: 'Новый дом',
        off_plan: 'Строящийся объект',
        resale: 'Вторичная недвижимость',
        floor: 'Этаж',
        floor_count: 'Этажность',
        bathroom_count: 'Количество ванных',
        bedroom_count: 'Количество спален',
        rent_per_year: 'Доходность в год',
      },
      en: {
        address: 'Address',
        location: 'Location',
        in: 'in',
        at: 'at',
        price_per_day: 'Price per day',
        price_per_week: 'Price per week',
        price_per_month: 'Price per month',
        to_beach: 'to the beach',
        to_airport: 'to the airport',
        to_railroad_station: 'to a railroad station',
        to_food_stores: 'to food stores',
        to_historical_city_center: 'to the historical city center',
        to_nearest_big_city: 'to the nearest big city',
        to_medical_facilities: 'to medical facilities',
        to_ski_lift: 'to a ski lift',
        to_metro_station: 'to a metro station',
        to_state_border: 'to a state border',
        room_count: 'Total number of rooms',
        site_plot: 'Site plot',
        house_area: 'House Area',
        floor_area: 'Floor area',
        date_of_construction: 'date of construction',
        completion_deadline: 'facility completion deadline',
        repair: 'repair',
        price_on_request: 'Price on request',
        studio: 'Studio',
        new_building: 'New building',
        off_plan: 'Off-plan',
        resale: 'Resale',
        floor: 'Floor',
        floor_count: 'Number of storeys',
        bathroom_count: 'Number of bathrooms',
        bedroom_count: 'Number of bedrooms',
        rent_per_year: 'Returns on investment per year'
      }
    }
  end

  def h1
    take_last_element_text('h1.c-header__title') || ''
  end

  def attributes
    attributes = {}
    table = response.css('tr.c-params__row')
    table.each do |tr|
      key = Parser::ParserUtils.delete_trailing_spaces(tr.css('.c-params__key').text)
      value = Parser::ParserUtils.delete_trailing_spaces(tr.css('.c-params__value').text)
      attributes[key] = value if key.present?
    end
    attributes
  end

  def description
    take_last_element_text('.translate_description.show') || ''
  end

  def imgs
    response.css('#imageGallery > li > img').map do |item|
      { src: Parser::ParserUtils.wrap_url(item['data-src']), alt: item['alt'] }
    end
  end

  def country
    attrs = attributes
    address = any_attribute(attrs, :address)
    address = address.split(',')
    address.first
  end

  def latitude
    response.body.match(/(?<=lat\s=\sparseFloat\(['"])-?\d*\.\d*/)[0]
  end

  def longitude
    response.body.match(/(?<=lng\s=\sparseFloat\(['"])-?\d*\.\d*/)[0]
  end

  def rest_address
    attrs = attributes
    address = any_attribute(attrs, :address)
    address = address.split(',')
    if address.second.present?
      address[1..-1].map { |location| Parser::ParserUtils.delete_trailing_spaces(location) }
    end
  end

  def additional_area
    any_attribute(attributes, :location)
  end

  def price
    price = take_last_element_text('.c-header__price')
    if price.present?
      Parser::ParserUtils.remove_non_numbers(price).to_i
    end
  end

  def type
    translations = %i[in at].flat_map { |anchor| locales.map { |locale| anchor_locales.dig(locale, anchor) } }
    regex = translations.join('|')

    h1.split(/ (?:#{regex})/).first
  end

  def external_link
    response.uri.to_s
  end

  def sale_price_unit
    price = take_last_element_text('.c-header__price')
    return if price.blank?
    sign = price.match(Parser::ParserUtils.icons_regex).to_s
    Formatters::PriceFormatter.currency_icon_to_name(sign)
  end

  def rent_price_per_day
    attrs = attributes
    rent = any_attribute(attrs, :price_per_day)
    if rent.present?
      Parser::ParserUtils.remove_non_numbers(rent).to_i
    end
  end

  def rent_price_unit_per_day
    attrs = attributes
    rent = any_attribute(attrs, :price_per_day)
    sign = rent.match(Parser::ParserUtils.icons_regex).to_s
    return if rent.blank?
    Formatters::PriceFormatter.currency_icon_to_name(sign)
  end

  def rent_price_per_week
    attrs = attributes
    rent = any_attribute(attrs, :price_per_week)
    if rent.present?
      Parser::ParserUtils.remove_non_numbers(rent).to_i
    end
  end

  def rent_price_unit_per_week
    attrs = attributes
    rent = any_attribute(attrs, :price_per_week)
    return if rent.blank?
    sign = rent.match(Parser::ParserUtils.icons_regex).to_s
    Formatters::PriceFormatter.currency_icon_to_name(sign)
  end

  def rent_price_per_month
    attrs = attributes
    rent = any_attribute(attrs, :price_per_month)
    if rent.present?
      Parser::ParserUtils.remove_non_numbers(rent).to_i
    end
  end

  def rent_price_unit_per_month
    attrs = attributes
    rent = any_attribute(attrs, :price_per_month)
    return if rent.blank?
    sign = rent.match(Parser::ParserUtils.icons_regex).to_s
    Formatters::PriceFormatter.currency_icon_to_name(sign)
  end

  def to_beach
    attrs = attributes
    length = any_attribute(attrs, :to_beach)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_beach_unit
    attrs = attributes
    length = any_attribute(attrs, :to_beach)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_airport
    attrs = attributes
    length = any_attribute(attrs, :to_airport)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_airport_unit
    attrs = attributes
    length = any_attribute(attrs, :to_airport)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_railroad_station
    attrs = attributes
    length = any_attribute(attrs, :to_railroad_station)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_railroad_station_unit
    attrs = attributes
    length = any_attribute(attrs, :to_railroad_station)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_food_stores
    attrs = attributes
    length = any_attribute(attrs, :to_food_stores)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_food_stores_unit
    attrs = attributes
    length = any_attribute(attrs, :to_food_stores)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_historical_city_center
    attrs = attributes
    length = any_attribute(attrs, :to_historical_city_center)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_historical_city_center_unit
    attrs = attributes
    length = any_attribute(attrs, :to_historical_city_center)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_nearest_big_city
    attrs = attributes
    length = any_attribute(attrs, :to_nearest_big_city)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_nearest_big_city_unit
    attrs = attributes
    length = any_attribute(attrs, :to_nearest_big_city)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_medical_facilities
    attrs = attributes
    length = any_attribute(attrs, :to_medical_facilities)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_medical_facilities_unit
    attrs = attributes
    length = any_attribute(attrs, :to_medical_facilities)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_ski_lift
    attrs = attributes
    length = any_attribute(attrs, :to_ski_lift)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_ski_lift_unit
    attrs = attributes
    length = any_attribute(attrs, :to_ski_lift)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_metro_station
    attrs = attributes
    length = any_attribute(attrs, :to_metro_station)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_metro_station_unit
    attrs = attributes
    length = any_attribute(attrs, :to_metro_station)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def to_state_border
    attrs = attributes
    length = any_attribute(attrs, :to_state_border)
    if length.present?
      Parser::ParserUtils.remove_non_numbers(length).to_i
    end
  end

  def to_state_border_unit
    attrs = attributes
    length = any_attribute(attrs, :to_state_border)
    if length.present?
      unit = Parser::ParserUtils.remove_numbers(length)
      Parser::ParserUtils.get_distance_type(unit)
    end
  end

  def is_active
    deactivate_image = take_last_element('.c-info-message > img')
    return true if deactivate_image.blank?

    deactivate_image['src'].include?('deact_rus.svg')
  end

  def building_year
    year_string = take_last_element_text('.c-addparams > p > i')
    return if year_string.blank?
    year_string.downcase!

    has_year = locales.any? do |locale|
      %i[date_of_construction completion_deadline].any? do |anchor|
        year_string.include?(get_translation(locale, anchor))
      end
    end

    if has_year
      year_string.match(/\d{4}(-\d{2}-\d{2})?/).to_s
    end
  end

  def last_repair
    year_string = take_last_element_text('.c-addparams > p > i')
    return if year_string.blank?
    year_string.downcase!

    if locales.any? { |locale| year_string.include?(get_translation(locale, :repair)) }
      year_string.match(/\d{4}(-\d{2}-\d{2})?/).to_s
    end
  end

  def room_count
    attrs = attributes
    room_count = any_attribute(attrs, :room_count)
    if room_count.present?
      Parser::ParserUtils.remove_non_numbers(room_count).to_i
    end
  end

  def price_on_request
    attrs = attributes
    locales.any? { |locale| attrs.has_key?(get_translation(locale, :price_on_request)) }
  end

  def area
    attrs = attributes
    area_string = any_attribute(attrs, :house_area) || any_attribute(attrs, :floor_area)
    return if area_string.blank?
    area_string.to_f # '150.25 м2' => 150.25
  end

  def area_unit
    attrs = attributes
    unit_str = any_attribute(attrs, :house_area) || any_attribute(attrs, :floor_area)
    return if unit_str.blank?
    unit = unit_str.split(' ').second
    Parser::ParserUtils.get_square_type(unit)
  end

  def plot_area
    attrs = attributes
    plot_string = any_attribute(attrs, :site_plot)
    return if plot_string.blank?
    plot_string.to_f # '150.25 м2' => 150.25
  end

  def plot_area_unit
    attrs = attributes
    plot_unit_str = any_attribute(attrs, :site_plot)
    return if plot_unit_str.blank?
    unit = plot_unit_str.split(' ').second
    Parser::ParserUtils.get_square_type(unit)
  end

  def studio
    response.css('.c-addparams > p b').any? do |el|
      localized_includes?(el.text, :studio)
    end
  end

  def construction_phase
    response.css('.c-addparams > p b').each do |el|
      return Property::CONSTRUCTION_PHASE_NEW if localized_includes?(el.text, :new_building)
      return Property::CONSTRUCTION_PHASE_OFF_PLAN if localized_includes?(el.text, :off_plan)
      return Property::CONSTRUCTION_PHASE_RESALE if localized_includes?(el.text, :resale)
    end
  end

  def level
    attrs = attributes
    lvl = any_attribute(attrs, :floor)
    return if lvl.blank?
    lvl.to_i
  end

  def level_count
    attrs = attributes
    lvl_count = any_attribute(attrs, :floor_count)
    return if lvl_count.blank?
    lvl_count.to_i
  end

  def bathroom_count
    attrs = attributes
    bathrooms = any_attribute(attrs, :bathroom_count)
    return if bathrooms.blank?
    bathrooms.to_i
  end

  def bedroom_count
    attrs = attributes
    bedrooms = any_attribute(attrs, :bedroom_count)
    return if bedrooms.blank?
    bedrooms.to_i
  end

  def rental_yield_per_year
    attrs = attributes
    rent = any_attribute(attrs, :rent_per_year)
    if rent.present?
      Parser::ParserUtils.remove_non_numbers(rent).to_i
    end
  end

  def rental_yield_per_year_unit
    attrs = attributes
    rent = any_attribute(attrs, :rent_per_year)
    if rent.present?
      Parser::ParserUtils.remove_numbers(rent).to_i
    end
  end

  def agency_link
    link = take_last_element('.companyinfo.c-anchor.c-contacts__company-name')
    Parser::ParserUtils.wrap_url(link['href']) if link.present?
  end

  def for_sale
    rent_price_per_day.blank? && rent_price_per_week.blank? && rent_price_per_month.blank?
  end
end

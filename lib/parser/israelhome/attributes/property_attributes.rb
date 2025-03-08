class Parser::Israelhome::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      ru: {
        city: 'город',
        type: 'тип',
        area: 'общая жил. площадь',
        plot_area: 'общая площадь',
        rooms: 'колличество комнат', # да с опечаткой, что поделать надо считывать
        beds: 'спальных мест',
        penthouse: 'пентхаус',
        penthouse_gen: 'пентхауса',
        townhouse: 'таунхаус',
        townhouse_gen: 'таунхауса',
        house: 'дом',
        house_gen: 'дома',
        apartment: 'апартамент',
        flat: 'квартир',
        flat_acc: 'квартиру',
        flat_gen: 'квартиры',
        villa: 'вилла',
        villa_acc: 'виллу',
        villa_gen: 'виллы',
        chalet: 'шале',
        bungalow: 'бунгало',
        elite_m: 'элитный',
        elite_n: 'элитное',
        elite_f: 'элитная',
        long_rent: 'долгосрочная аренда',
        short_rent: 'краткосрочная аренда апартаментов',
        rent: 'аренда',
        per_day: 'цена сутки',
        other_country: 'недвижимость в других странах',
      },
      en: {
        city: 'city',
        type: 'type',
        area: 'total living space',
        plot_area: 'total space',
        rooms: 'number of rooms',
        beds: 'beds',
        penthouse: 'penthouse',
        townhouse: 'townhouse',
        house: 'house',
        apartment: 'apartment',
        flat: 'flat',
        villa: 'villa',
        chalet: 'chalet',
        bungalow: 'bungalow',
        elite: 'elite',
        long_rent: 'long-term rentals',
        short_rent: 'short-term apartment rental',
        rent: 'rent',
        per_day: 'price day',
        other_country: 'real estate in other countries',
      },
    }
  end

  def h1
    take_last_element_text('#squeeze > h1')
  end

  def attributes
    attrs = response.css('ul.atts li')
    attrs.reduce({}) do |result, el|
      text = Parser::ParserUtils.delete_trailing_spaces(el.text.downcase)
      attr_type, attr_value = text.split(':')
      attr_value = Parser::ParserUtils.delete_trailing_spaces(attr_value)

      if localized_includes?(attr_type, :city)
        city = el.children.to_a.filter(&:text?).join.gsub("▼", '')
        result[:city] = Parser::ParserUtils.delete_trailing_spaces(city)
      elsif localized_includes?(attr_type, :type)
        result[:type] = attr_value
      elsif localized_includes?(attr_type, :area)
        result[:area] = attr_value
      elsif localized_includes?(attr_type, :plot_area)
        result[:plot_area] = attr_value
      elsif localized_includes?(attr_type, :rooms)
        result[:rooms] = attr_value
      elsif localized_includes?(attr_type, :beds)
        result[:beds] = attr_value
      end
      result
    end
  end

  # http://israelhome.ru/rus/realestate/lot1147/
  def property_tags
    # 1trd_p_bl - не валидный CSS класс и Nokogiri кидает исключение, но нам то его получить надо
    property_comfort_icons = response.css('[class~="1trd_p_bl"] img')

    return if property_comfort_icons.blank?

    property_comfort_icons.map do |el|
      {
        title_ru: el['title'],
        title_en: el['title'],
      }
    end
  end

  def map_link_coords
    map = take_last_element('[class~="1trd_p_bl"] #mapa')
    return if map.blank?
    coordinate_regex = /(?<=c=)([\d.]+:[\d.]+)/
    link = coordinate_regex.match(map['href'])
    return if link.blank?

    coords = link[0].split(':')
    {
      latitude: coords[0],
      longitude: coords[1]
    }
  end

  def latitude
    map_link_coords&.fetch(:latitude, nil)
  end

  def longitude
    map_link_coords&.fetch(:longitude, nil)
  end

  def type_group
    type_locales = {
      house: %i[house house_gen],
      apartment: %i[apartment],
      flat: %i[flat flat_acc flat_gen],
      penthouse: %i[penthouse penthouse_gen],
      chalet: %i[chalet],
      villa: %i[villa villa_acc villa_gen],
      bungalow: %i[bungalow],
      townhouse: %i[townhouse],
      elite_f: %i[elite_m elite_n elite_f],
      rent: %i[long_rent short_rent],
      other_country: %i[other_country],
    }
    type_attr = attributes[:type]

    type_locales.each do |common, inclined|
      translated = map_locales(inclined)

      search_subject = type_attr || h1.downcase

      if translated.any? { |translation| translation.in?(search_subject) }
        return common
      end
    end
  end

  def type
    get_translation(:ru, type_group)
  end

  def country_ru
    'Израиль'
  end

  def country_en
    'Israel'
  end

  def rest_address
    attributes[:city]
  end

  def external_link
    response.uri.to_s
  end

  def for_sale
    !localized_includes?(price_type, :per_day)
  end

  def sale_price
    return unless for_sale
    price
  end

  def price
    price_text = take_last_element_text('span[itemprop="price"]')
    return 0 if price_text.blank?

    Parser::ParserUtils.remove_non_numbers(price_text).to_i
  end

  def sale_price_unit
    price_text = take_last_element_text('span[itemprop="price"]')
    return 'USD' if price_text.blank?

    sign = price_text.match(Parser::ParserUtils.icons_regex).to_s
    Formatters::PriceFormatter.currency_icon_to_name(sign)
  end

  def price_type
    take_last_element('.isec_p_bl')
      &.children
      &.select(&:text?)
      &.join
      &.downcase
  end

  def rent_price_per_day
    return if for_sale
    price
  end

  def price_on_request
    price == 0
  end

  def area
    area_text = attributes[:area]
    if area_text.present?
      Parser::ParserUtils.remove_non_numbers(area_text)
    end
  end

  def area_unit
    area_text = attributes[:area]
    if area_text.present?
      unit = Parser::ParserUtils.remove_numbers(area_text)
      Parser::ParserUtils.get_square_type(unit)
    end
  end

  def plot_area
    area_text = attributes[:plot_area]
    if area_text.present?
      Parser::ParserUtils.remove_non_numbers(area_text)
    end
  end

  def plot_area_unit
    area_text = attributes[:plot_area]
    if area_text.present?
      unit = Parser::ParserUtils.remove_numbers(area_text)
      Parser::ParserUtils.get_square_type(unit)
    end
  end

  def is_active
    take_last_element('#filter').blank? # при 404 открывается каталог поиска и фильтр
  end

  def description
    descr_text = take_last_element_text('.t_desc[itemprop="description"]')
    Parser::ParserUtils.delete_trailing_spaces(descr_text)
  end

  def imgs
    response.css('a[rel="lot_pic"]').map do |el|
      {
        src: "http://#{response.uri.host}#{el['href']}",
        alt: el['alt']
      }
    end
  end

  def agency_link
    "http://#{response.uri.host}/"
  end

  def bedroom_count
    attributes[:beds]&.to_i
  end

  def room_count
    attributes[:rooms]&.to_i
  end
end

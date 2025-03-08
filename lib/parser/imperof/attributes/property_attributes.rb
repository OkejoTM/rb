class Parser::Imperof::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      ru: {
        bedroom: 'спальня',
        bedroom_pl: 'спальни', # мн.ч.
        bedroom_pl_gen: 'спален', # мн.ч., Род.п.
        bathroom: 'ванная',
        bathroom_pl: 'ванные', # мн.ч.
        room: 'комната',
        year_built: 'год постройки',
        house: 'дом',
        apartment: 'апартамент',
        flat: 'квартира',
        penthouse: 'пентхаус',
        chalet: 'шале',
        villa: 'вилла',
        bungalow: 'бунгало',
        townhouse: 'таунхаус',
        call_for_price: 'позвоните, чтобы узнать цену',
        area_size: 'Площадь',
        studio: 'студия',
        for_sale: 'продажа',
      },
      en: {
        bedroom: 'bedroom',
        bathroom: 'bathroom',
        room: 'room',
        year_built: 'year built',
        house: 'house',
        apartment: 'apartment',
        flat: 'flat',
        penthouse: 'penthouse',
        chalet: 'chalet',
        villa: 'villa',
        bungalow: 'bungalow',
        townhouse: 'townhouse',
        call_for_price: 'call for price',
        area_size: 'Area Size',
        studio: 'studio',
        for_sale: 'for_sale',
      },
    }
  end

  def h1
    take_last_element_text('h1.page-title span')
  end

  def attributes
    bedroom_regex = map_locales(%i[bedroom bedroom_pl bedroom_pl_gen]).join('|')
    bathroom_regex = map_locales(%i[room bathroom bathroom_pl]).join('|')
    years_regex = map_locales(%i[year_built]).join('|')

    response
      .css('.property-meta.clearfix span')
      .map do |span|
        title = span['title']
        text = Parser::ParserUtils.delete_trailing_spaces(span.text)

        title =
          if title.blank?
            if text.match(/#{bedroom_regex}/i)
              'Количество спален'
            elsif text.match(/#{bathroom_regex}/i)
              'Количество ванных комнат'
            elsif text.match(/#{years_regex}/i)
              'Год постройки'
            end
          end

        next if title.blank?

        text = text.to_i
        [title, text]
      end
      .compact
      .to_h
  end

  def latitude
    res = response
      .body
      .match(Parser::Imperof::Pages::ParserUtils.coordinate_regex('lat'))

    return res.to_f if res.blank?

    res.captures.first.to_f
  end

  def longitude
    res = response
      .body
      .match(Parser::Imperof::Pages::ParserUtils.coordinate_regex('lang'))

    return res.to_f if res.blank?

    res.captures.first.to_f
  end

  def type
    type_locales = %i[house apartment flat penthouse chalet villa bungalow townhouse]
    translated = map_locales(type_locales)

    h1.downcase.split.find { |word| word.in?(translated) }
  end

  def sale_price_unit
    'EUR'
  end

  def country_ru
    'Италия' # HACK: Всегда ли так будет?
  end

  def country_en
    'Italy' # HACK: Всегда ли так будет?
  end

  def rest_address
    response
      .css('address')
      .text
      &.split(',')
      &.map { |w| Parser::ParserUtils.delete_trailing_spaces(w) }
  end

  def external_link
    response.uri.to_s
  end

  def is_active
    title = h1

    !'404'.in?(title)
  end

  def price
    return if price_on_request

    price_or_request = response
      .at('.price-and-type')
      .children
      .select(&:text?)
      .map { |text_node| Parser::ParserUtils.delete_trailing_spaces(text_node.text) }
      .select(&:present?)
      .select { |text| text.starts_with?(Parser::ParserUtils.icons_regex) || text.length > 5 } # начинается с символа валюты или достаточно длинное число
      &.first
    price_or_request.match(/\d+/)[0].to_i
  end

  def building_year
    # https://imperof.com/it/property/%d0%b2%d0%b8%d0%bb%d0%bb%d0%b0-%d0%b2-%d0%ba%d0%b0%d0%bc%d0%b1%d0%be%d1%80%d0%b4%d0%b6%d0%b0%d0%bd%d0%be/
    year = attributes['Год постройки']
    return if year.blank?
    Parser::ParserUtils.only_year_format(year.to_s)
  end

  def price_on_request
    # https://imperof.com/ru/property/%D0%B2%D0%B8%D0%BB%D0%BB%D0%B0-%D1%81-%D1%81%D0%B0%D0%B4%D0%BE%D0%BC-%D0%B2-%D0%B0%D1%80%D0%B5%D0%BD%D0%B4%D1%83-%D0%B2-500-%D0%BC%D0%B5%D1%82%D1%80%D0%B0%D1%85-%D0%BE%D1%82-%D0%BC%D0%BE%D1%80%D1%8F/
    # https://imperof.com/en/property/1302-2/
    price_or_request = Parser::ParserUtils.delete_trailing_spaces(response.css('.price-and-type').text)&.downcase
    return false if price_or_request.blank?

    type_locales = %i[call_for_price]
    translated = map_locales(type_locales)
      .map { |translation| "(#{translation})" }
      .join('|')
    price_or_request.match(/#{translated}/i).present?
  end

  def area
    # https://imperof.com/en/property/1302-2/
    area = nil

    locales.each do |locale|
      area ||= take_last_element("[title=\"#{get_translation(locale, :area_size)}\"]")
    end

    return if area.blank?

    area.text.to_f
  end

  def area_unit
    # https://imperof.com/en/property/2235-2/ # кв. м.
    # https://imperof.com/ru/property/2235-2/ # кв. фут.
    area = nil

    locales.each do |locale|
      area ||= take_last_element_text("[title=\"#{get_translation(locale, :area_size)}\"]")
    end

    return if area.blank?

    unit = area.split(' ').second
    return Formatters::AreaFormatter::AREA_UNIT_SQ_M if unit.blank?

    Parser::ParserUtils.get_square_type(unit.downcase)
  end

  def description
    take_last_element_text('.content.clearfix')
  end

  def studio
    translated = map_locales(%i[studio])
    h1.downcase.split.any? { |word| word.in?(translated) }
  end

  def imgs
    response.css('ul.slides li a').map do |a|
      { src: a['href'], alt: a['alt'] }
    end
  end

  def agency_link
    uri = URI.parse(take_last_element('#logo a')['href'])
    Parser::ParserUtils.wrap_url("//#{uri.host}")
  end

  def bathroom_count
    attributes['Количество ванных комнат']
  end

  def bedroom_count
    attributes['Количество спален']
  end

  def for_sale
    selling_type = Parser::ParserUtils.delete_trailing_spaces(take_last_element_text('.price .status-label')&.downcase)

    return true if selling_type.blank? # https://imperof.com/ru/property/просторная-вилла-в-лидо-ди-камайоре/

    translated = map_locales(%i[for_sale])

    translated.any? { |word| word.in?(selling_type) }
  end
end

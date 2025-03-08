class Parser::SmartRich::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  # https://afy.ru/auto_download
  # Собственный формат AFY

  CATEGORIES = {
      '31': 'Земельный участок (Продажа)',
      '200': 'Промышленная земля (Продажа)',

      '175': 'Квартира (Продажа)',
      '666': 'Квартира (Аукцион)',
      '187': 'Квартира (Обмен)',
      '208': 'Квартира (Аренда)',
      '213': 'Квартира (Аренда посуточно)',
      '216': 'Пентхаус (Продажа)',

      '189': 'Комната (Продажа)',
      '190': 'Комната (Обмен)',
      '234': 'Комната (Аренда)',
      '262': 'Комната (Аренда посуточно)',

      '102': 'Дом (Продажа)',
      '50': 'Дом (Аренда)',
      '124': 'Дом (Аренда посуточно)',
      '195': 'Дом (Аренда на Новый год)',
      '103': 'Дача (Продажа)',
      '193': 'Таунхаус (Продажа)',

      '202': 'Гараж (Продажа)',
      '203': 'Гараж (Аренда)',

      '197': 'Торговое помещение (Продажа)',
      '196': 'Торговое помещение (Аренда)',

      '199': 'Склад (Продажа)',
      '198': 'Склад (Аренда)',
      '255': 'Производственное помещение (Продажа)',
      '256': 'Производственное помещение (Аренда)',
      '253': 'ПСН (Продажа)', # Помещения свободного назначения
      '254': 'ПСН (Аренда)',

      '191': 'Офис (Продажа)',
      '180': 'Офис (Аренда)',

      '201': 'Готовый бизнес (Продажа)',

  }.freeze


  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      en: {
        day: 'day',
        month: 'month',
        year: 'year',
        exchange: 'exchange',
        auction: 'auction',
      },
      ru: {
        sale: 'продажа',
        rent: 'аренда',
        day: 'день',
        month: 'месяц',
        year: 'год',
        exchange: 'обмен',
        auction: 'аукцион',
      }
    }
  end

  def h1_ru
    take_last_element_text('theme')
  end

  def description_ru
    take_last_element_text('description')
  end

  def studio
    studio_text = take_last_element_text('studio', resp: parameters_block)
    return false if studio_text.blank?

    studio_text.downcase.in?(truthy)
  end

  def latitude
    take_last_element_text('latitude', resp: location_block)&.to_f
  end

  def longitude
    take_last_element_text('longitude', resp: location_block)&.to_f
  end

  def category_type_with_selling_type
    cat_id = take_last_element_text('category')
    CATEGORIES.fetch(cat_id.to_sym)
  end

  def property_type
    cat_str = category_type_with_selling_type
    cat_str.gsub(/\s\(\D+\)/, '')
  end

  # <price>
  #   <currency>EUR</currency>
  #   <value>88200</value>
  #   <unit>total</unit>
  # </price>
  def price_unit
    take_last_element_text('currency', resp: price_block)
  end

  def price
    price = take_last_element_text('value', resp: price_block)
    price_type = take_last_element_text('unit', resp: price_block)

    raise StandardError.new("In supported type of price #{price_type}") if price_type != 'total'

    price
  end

  def rent_price_per_day
    price if per_day?
  end

  def rent_price_per_month
    price if per_month?
  end

  def rent_price_per_year
    price if per_year?
  end

  def price_on_request?
    price.blank?
  end

  def country
    take_last_element_text('country', resp: location_block)
  end

  def region
    take_last_element_text('oblast', resp: location_block)
  end

  def city
    take_last_element_text('city', resp: location_block)
  end

  # Добавлено для обратной совместимости с Operation#find_region Operation#find_city
  def rest_address
    "#{region.to_s} #{city.to_s}"
  end

  def external_link
    take_last_element_text('original_url')
  end

  def for_sale
    selling_type = category_type_with_selling_type
      .match(/\(\D+\)/)[0]
      &.gsub(/[()]/, '')
      &.downcase

    if map_locales(%i[exchange auction]).any? { |type| type.in?(selling_type) }
      raise StandardError.new("Unsupported sale type #{selling_type}")
    end

    get_translation(:ru, :sale).in?(selling_type)
  end

  # <year_bild>0</year_bild>
  # в формате ГГГГ
  def building_year
    year = take_last_element_text('year_bild', resp: parameters_block)

    return if year.blank?

    Parser::ParserUtils.only_year_format(year.to_s)
  end

  def room_count
    take_last_element_text('rooms', resp: parameters_block)&.to_i
  end

  def area
    take_last_element_text('total', resp: square_block)&.to_f
  end

  # sq_m – квадратный метр
  # hundred_sq_m – сотка
  # hectare – гектар
  def square_unit
    unit = take_last_element_text('unit', resp: square_block)
    Parser::ParserUtils.get_square_type(unit)
  end

  def plot_area
    take_last_element_text('land', resp: square_block)&.to_f
  end

  def agency_link
    'https://smartandrich.ru/'
  end

  def imgs
    response.css('image').map do |node|
      { src: node.text }
    end
  end

  def level
    floor = take_last_element_text('story', resp: parameters_block)
    return if floor.blank?

    floor.to_i
  end

  def level_count
    floors = take_last_element_text('story_count', resp: parameters_block)
    return if floors.blank?

    floors.to_i
  end

  def bathroom_count
    bathroom = take_last_element_text('count_bathroom', resp: parameters_block)
    return if bathroom.blank?

    bathroom.to_i
  end

  def bedroom_count
    bedroom = take_last_element_text('count_bedroom', resp: parameters_block)
    return if bedroom.blank?

    bedroom.to_i
  end

  def is_active
    # считаем, что все недвижимости в файле являются активными
    true
  end

  protected

    def parameters_block
      take_last_element('parameters')
    end

    def price_block
      take_last_element('price')
    end

    def location_block
      take_last_element('location')
    end

    def square_block
      take_last_element('square')
    end

    def rent_period
      take_last_element_text('period', resp: price_block)
    end

    def per_day?
      return false if rent_period.blank?
      localized_includes?(rent_period, :day)
    end

    def per_month?
      return false if rent_period.blank?
      localized_includes?(rent_period, :month)
    end

    def per_year?
      return false if rent_period.blank?
      localized_includes?(rent_period, :year)
    end

  private

    def truthy
      %w[+ 1 true да y]
    end
end

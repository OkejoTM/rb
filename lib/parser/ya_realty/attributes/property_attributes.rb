class Parser::YaRealty::Attributes::PropertyAttributes < Parser::BaseAttributes
  include Parser::PropertyBaseAttributes

  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      en: {
        price_on_request: 'price on request',
        day: 'day',
        month: 'month',
      },
      ru: {
        sale: 'продажа',
        rent: 'аренда',
        day: 'день',
        month: 'месяц',
      }
    }
  end

  def offer
    take_last_element('offer')[:'internal-id']
  end

  def description_ru
    take_last_element_text('description')
  end

  def description_en
    take_last_element_text('description-en')
  end

  def studio
    studio_text = take_last_element_text('studio')
    return false if studio_text.blank?

    studio_text.downcase.in?(truthy)
  end

  def latitude
    take_last_element_text('latitude')&.to_f
  end

  def longitude
    take_last_element_text('longitude')&.to_f
  end

  def property_type
    take_last_element_text('offer > category')
  end

  # <price>
  # <value>5000000<value/>
  # <currency>RUB<currency/>
  # </price>
  def price_unit
    # price_block.css('currency').last.text
    take_last_element_text('currency', resp: price_block)
  end

  def price
    # price_block.css('value').last.text
    take_last_element_text('value', resp: price_block)&.downcase
  end

  def sale_price
    price unless price_on_request?
  end

  # <price>
  # <value>30000<value/>
  # <currency>RUB<currency/>
  # <period>месяц<period/>
  # </price>
  def rent_price_per_day
    price if per_day?
  end

  def rent_price_per_month
    price if per_month?
  end

  def price_on_request?
    price == get_translation(:en, :price_on_request)
  end

  def country
    take_last_element_text('country', resp: location_block)
  end

  def region
    take_last_element_text('region', resp: location_block)
  end

  def city
    take_last_element_text('locality-name', resp: location_block)
  end

  # Добавлено для обратной совместимости с Operation#find_region Operation#find_city
  def rest_address
    "#{region.to_s} #{city.to_s}"
  end

  def external_link
    take_last_element_text('offer > url')
  end

  def grabber_link
    take_last_element_text('url')
  end

  def for_sale
    take_last_element_text('type').downcase.in?(map_locales(%i[sale rent]))
  end

  def building_year
    year = take_last_element_text('built-year')

    return if year.blank? || year.to_i.zero?

    Parser::ParserUtils.only_year_format(year.to_s)
  end

  def room_count
    take_last_element_text('rooms')&.to_i
  end

  def area
    take_last_element_text('value', resp: area_block)
  end

  # «кв. м»/«sq. m»
  # «сотка»
  # «гектар»/«hectare».
  def area_unit
    # take_last_element_text('unit', resp: area_block)
    get_area_unit(area_block)
  end

  def plot_area
    take_last_element_text('value', resp: plot_area_block)
  end

  # «кв.м»/«sq.m»
  # «сотка»
  # «гектар»/«hectare».
  def plot_area_unit
    get_area_unit(plot_area_block)
  end

  def agency_link
    agent_block = take_last_element('sales-agent')
    take_last_element_text('url', resp: agent_block)
  end

  def imgs
    response.css('image').map do |node|
      { src: node.text }
    end
  end

  def level
    floor = take_last_element_text('floor')
    return if floor.blank?

    floor
  end

  def level_count
    floors = take_last_element_text('floors-total')
    return if floors.blank?

    floors.to_i
  end

  def bathroom_count
    bathroom = take_last_element_text('bathroom-unit')
    return if bathroom.blank?
    return if bathroom.to_i.zero?

    bathroom.to_i
  end

  def to_airport
    take_last_element_text('airport_distance')&.to_i
  end

  def default_distance_unit
    Formatters::DistanceFormatter::DISTANCE_UNIT_METERS
  end

  def to_historical_city_center
    take_last_element_text('airport_distance')&.to_i
  end

  def to_sea
    take_last_element_text('sea_distance')&.to_i
  end

  def is_active
    # считаем, что все недвижимости в файле являются активными
    true
  end

  protected

    def price_block
      take_last_element('price')
    end

    def location_block
      take_last_element('location')
    end

    def area_block
      take_last_element('area')
    end

    def plot_area_block
      take_last_element('lot-area')
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

    def get_area_unit(resp)
      unit = take_last_element_text('unit', resp: resp)
      return if unit.blank?

      Parser::ParserUtils.get_square_type(unit)
    end

    def truthy
      %w[+ 1 true да]
    end
end

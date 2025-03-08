class Parser::Grekodom::Attributes::PropertyAttributes < Parser::YaRealty::Attributes::PropertyAttributes
  include Parser::PropertyBaseAttributes

  # https://yandex.ru/support/realty/requirements/requirements-sale-housing.html
  # Формат грекодома отличается от формата Яндекса в некоторых тегах
  # ГД: year_builtbuilt, YA: built-year
  # ГД: options, YA: Отсутствует

  # <year_builtbuilt>0</year_builtbuilt>
  # Используемый тэг не опечатка
  def building_year
    year = take_last_element_text('year_builtbuilt', resp: options_block)

    return if year.blank? || year.to_i.zero?

    Parser::ParserUtils.only_year_format(year.to_s)
  end

  def bathroom_count
    bathroom = take_last_element_text('bathrooms', resp: options_block)
    return if bathroom.blank?

    bathroom.to_i
  end

  def bedroom_count
    bedroom = take_last_element_text('bedrooms', resp: options_block)
    return if bedroom.blank?

    bedroom.to_i
  end

  def agency_link
    'https://www.grekodom.ru'
  end

  protected

    def options_block
      take_last_element('options')
    end
end

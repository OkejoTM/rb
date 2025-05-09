module Parser::ParserUtils
  extend self

  def wrap_url(href)
    "https:#{href}"
  end

  def icons_regex
    /[$€₽]/
  end

  def delete_trailing_spaces(str)
    str.strip.gsub(/[\n\r\t]/, '').squeeze(' ') if str.present?
  end

  def img_exist?(img_url)
    return false if img_url.blank?

    begin
      url = URI.parse(img_url)
    rescue URI::InvalidURIError => e
      # Пробуем преобразовать в URI safe, если не удалось понять URI
      # URI::regexp считает ссылки с пробелами валидными, так что опираемся на исключения
      img_url_safe = URI.encode(img_url)

      img_url_safe.gsub!('[', '%5B')
      img_url_safe.gsub!(']', '%5D')

      url = URI.parse(img_url_safe)
    end

    return false if url.path.blank?

    connection = Net::HTTP.new(url.host, url.port)
    connection.use_ssl = img_url.starts_with?('https')

    head = connection.request_head(url)

    head.kind_of?(Net::HTTPSuccess) && head.content_type.starts_with?('image')
  end

  def remove_non_numbers(str)
    str.gsub(/\D/, '')
  end

  def remove_numbers(str)
    str.gsub(/[\d\s]/, '')
  end

  def only_year_format(str)
    Date::strptime(str, "%Y")
  end

  def get_square_type(snippet)
    case snippet
      when "м2", "м", "кв.м", "кв. м", "sq. m", "кв. м.", "sq. m.", "кв.м.", "sq.m.", "sq_m"
        Formatters::AreaFormatter::AREA_UNIT_SQ_M
      when "сот.", "сотка", "hundred_sq_m"
        Formatters::AreaFormatter::AREA_UNIT_ARES
      when "Га", "гектар", "hectare"
        Formatters::AreaFormatter::AREA_UNIT_HECTARES
      when "акров"
        Formatters::AreaFormatter::AREA_UNIT_ACRES
      when "sq.ft.", "sq ft", "кв.фт.", "кв фт"
        Formatters::AreaFormatter::AREA_UNIT_ACRES
      else
        -1
    end
  end

  def get_distance_type(snippet)
    case snippet
      when "м", "0"
        Formatters::DistanceFormatter::DISTANCE_UNIT_METERS
      when "км"
        Formatters::DistanceFormatter::DISTANCE_UNIT_KILOMETERS
      when "миль"
        Formatters::DistanceFormatter::DISTANCE_UNIT_MILES
      else
        -1
    end
  end
end

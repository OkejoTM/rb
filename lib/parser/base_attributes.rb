class Parser::BaseAttributes
  attr_reader :response

  def initialize(response)
    @response = response
  end

  protected

    # Берет последний элемент на странице в соответствии с правилом
    # @param [String] css_rule правило аналогичное JQuery
    # @param [Nokogiri::Node] resp
    # @return [Nokogiri::Node|Nil]
    def take_last_element(css_rule, resp: response)
      return if resp.blank?
      resp.css(css_rule).last
    end

    # Берет видимую(текстовую) часть последнего элемента на странице в соответствии с правилом
    # @param [String] css_rule
    # @param [Nokogiri::Node] resp
    # @return [String|Nil]
    def take_last_element_text(css_rule, resp: response)
      take_last_element(css_rule, resp: resp)&.text
    end

    # Различные переводы, которые помогают при парсинге и локальны для сайта
    def anchor_locales
      {}
    end

    # Доступные локали
    def locales
      %i[]
    end

    # Позволяет получить перевод по соответствующему лейблу
    # @param [Symbol] locale язык (en, ru, etc)
    # @param [Symbol] anchor лейбл
    # @return [String]
    def get_translation(locale, anchor)
      anchor_locales.dig(locale, anchor)
    end

    # Достает первое соответствующее переводу значение из хэша
    # @param [Hash] attrs хэш с ключами - переводами
    # @param [Symbol] anchor лейбл
    # @return [String]
    def any_attribute(attrs, anchor)
      value = nil

      locales.each do |locale|
        value = attrs[get_translation(locale, anchor)]
        break if value.present?
      end
      value
    end

    # Проверяет есть ли в строке +text+ подстрока соответствующая вариантам перевода +anchor+
    # @param [String] text
    # @param [Symbol] anchor лейбл
    # @return [Boolean]
    def localized_includes?(text, anchor)
      locales.any? { |locale| text.include?(get_translation(locale, anchor)) }
    end

    # Создает массив из всех доступных переводов для нужных слов
    # Example: map_locales(%i[flat house]) => [flat, квартира, house, дом]
    # @param [Array] list_of_anchors список локалей
    # @return [Array] список переведенных локалей
    def map_locales(list_of_anchors)
      list_of_anchors
        .flat_map { |anchor| locales.map { |locale| get_translation(locale, anchor) } }
        .compact
    end
end

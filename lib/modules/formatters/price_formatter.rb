require 'active_support/number_helper'

module Formatters::PriceFormatter
  extend ActiveSupport::NumberHelper

  class << self
    def format_price(property, currency: CurrencyRate::DEFAULT_CURRENCY)
      return I18n.t(:price_on_request, scope: :properties) if property.price_on_request?

      rounded_price = round_price(property.sale_price(currency: currency), currency: currency)
      format_money(rounded_price, currency: currency)
    end

    def format_price_for_area(property, currency: CurrencyRate::DEFAULT_CURRENCY)
      if property.sale_price.present? && property.area.present? && !property.price_on_request? && !property.area.zero?

        price_for_area = property.sale_price(currency: currency) / property.area
        rounded_price = round_price_for_area(price_for_area, currency: currency)
        return "#{format_money(rounded_price, currency: currency)} / #{Formatters::AreaFormatter.format_area_unit(property.area_unit)}"
      end
      ""
    end

    def format_money(money, currency: CurrencyRate::DEFAULT_CURRENCY)
      ActiveSupport::NumberHelper.number_to_currency(money,
                                                     precision: 0,
                                                     unit: CurrencyRate.currency_symbol(currency),
                                                     separator: '.',
                                                     delimiter: ' ',
                                                     format: "%n %u"
      )
    end

    # Округляет цену в зависимости от валюты
    # @param [Integer] money цена
    # @param [String] currency аббревиатура валюты
    # @example round_price(10530, "USD") #=> "10500"
    # @return [Integer]
    def round_price(money, currency: CurrencyRate::DEFAULT_CURRENCY)
      money.round(price_rounding_value(currency))
    end

    # Округляет цену за единицу площади в зависимости от валюты
    # @param [Integer] money цена
    # @param [String] currency аббревиатура валюты
    # @example round_price_for_area(10533, "USD") #=> "10530"
    # @return [Integer]
    def round_price_for_area(money, currency: CurrencyRate::DEFAULT_CURRENCY)
      money.round(price_for_area_rounding_value(currency))
    end

    # Величина округления цены для заданной валюты
    # @param [String] currency аббревиатура валюты
    # @example currency_rounding_value("USD") #=> "-2"
    # @return [Integer]
    def price_rounding_value(currency)
      case currency
        when 'EUR' then -2
        when 'RUB' then -3
        when 'USD' then -2
        else -2
      end
    end

    # Величина округления цены за единицу площади для заданной валюты
    # @param [String] currency аббревиатура валюты
    # @example price_for_area_rounding_value("USD") #=> "-1"
    # @return [Integer]
    def price_for_area_rounding_value(currency)
      case currency
        when 'EUR' then -1
        when 'RUB' then -2
        when 'USD' then -1
        else -1
      end
    end

    # Конвертирует символ валюты в аббревиатуру
    # Пример: $ => USD
    # @param [String] sign
    # @return [String]
    def currency_icon_to_name(sign)
      {
        '€': 'EUR',
        '$': 'USD',
        '₽': 'RUB'
      }.fetch(sign.to_sym, sign)
    end
  end
end

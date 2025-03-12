module Priceable
  extend ActiveSupport::Concern

  # Определяет является ли цена по запросу
  # @return [Boolean] цена по запросу
  # @example
  #   Property.first.price_on_request?
  def price_on_request?
    super || sale_price.nil? || sale_price == 0
  end

  # Возвращает цену недвижимости в заданной валюте
  # @param [Object] currency валюта, в которой должна быть получена цена недвижимости
  # @return [Integer]
  def sale_price(currency: CurrencyRate::DEFAULT_CURRENCY)
    if currency == CurrencyRate::DEFAULT_CURRENCY
      super() # NOTE: не надо убирать скобки отсюда
    else
      CurrencyConverter.convert(value: super(), to: currency) # NOTE: не надо убирать скобки у super отсюда
    end
  end
end

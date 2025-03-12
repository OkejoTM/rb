# == Schema Information
#
# Table name: currency_rates
#
#  id     :bigint           not null, primary key
#  abbrev :string
#  rate   :float
#  date   :date
#

class CurrencyRate < ApplicationRecord
  # @todo вероятно, необходимо вынести отсюда (возможно, в настройки сайта)
  DEFAULT_CURRENCY = 'EUR'
  ACTIVE_CURRENCIES = %w[EUR USD RUB]

  scope :for_today, -> { where(date: Date.today) }

  class << self
    # Возвращает символ валюты по её аббревиатуре
    # @param [String] currency_abbrev аббревиатура валюты
    # @example currency_symbol("USD") #=> "$"
    # @return [String]
    def currency_symbol(currency_abbrev)
      case currency_abbrev
        when 'EUR' then '€'
        when 'RUB' then '₽'
        when 'USD' then '$'
        else currency_abbrev
      end
    end
  end
end

class CurrencyConverter
  class << self
    # Конвертирует значение из одной валюты в другую за определенный день
    # @param [Numeric] value
    # @param [String] from
    # @param [String] to
    # @param [Date] date
    # @return [Float] конвертированное значение
    def convert(
      value:,
      from: CurrencyRate::DEFAULT_CURRENCY,
      to:,
      date: Date.today
    )

      rate_from = (CurrencyRate.find_by(date: date, abbrev: from.to_s.upcase) ||
                   CurrencyRate.where(abbrev: from.to_s.upcase).last).rate
      rate_to = (CurrencyRate.find_by(date: date, abbrev: to.to_s.upcase) ||
                 CurrencyRate.where(abbrev: to.to_s.upcase).last).rate

      (value * (rate_to / rate_from)).to_f
    end
  end
end

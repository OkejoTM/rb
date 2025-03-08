namespace :currency do
  task update_rates: :environment do
    EUROCB_STATS_URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"

    stats = Net::HTTP::get(URI(EUROCB_STATS_URL))
    currencies = Nokogiri::XML(stats).css('Cube[@currency]')

    currencies.each do |c|
      currency = CurrencyRate.find_or_initialize_by(date: Date.today, abbrev: c[:currency])
      currency.rate = c[:rate].to_f
      currency.save!
    end

    # Tiny hack to ease further work with currencies :)
    default_currency = CurrencyRate.find_or_initialize_by(date: Date.today, abbrev: CurrencyRate::DEFAULT_CURRENCY)
    default_currency.rate = 1
    default_currency.save!
  end
end

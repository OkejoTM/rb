namespace :parse_turkey do
  task run: :environment do
    next unless PropimoSettings.on?('parser')

    begin
      PropimoSettings.set('parser', false) # Защищаем таску от параллельного запуска

      RealEstateParser.joins(:agency).where(agencies: { name_en: 'vartur' }).first.start
    ensure
      PropimoSettings.set('parser', true)
    end
  end
end

namespace :parse_turkey do
  task run: :environment do
    next unless PropimoSettings.on?('parser')

    begin
      PropimoSettings.set('parser', false) # Защищаем таску от параллельного запуска

      Parsers::Vartur::Schema.new(
        Parser::AgentProxy.new,
        Parsers::RealEstateParserLogger.new("log/parsers", RealEstateParser.joins(:agency).where(agencies: { name_en: 'vartur' }).first)
      ).call
    ensure
      PropimoSettings.set('parser', true)
    end
  end
end

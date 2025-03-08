namespace :parse_turkey do
  task run: :environment do
    next unless PropimoSettings.on?('parser')

    begin
      PropimoSettings.set('parser', false) # Защищаем таску от параллельного запуска

      logger = Logger.new('log/parsers/vartur.log')
      logger.level = Logger::INFO

      Parsers::Vartur::Schema.new(
        Parser::AgentProxy.new,
        logger
      ).call()
    ensure
      PropimoSettings.set('parser', true)
    end
  end
end

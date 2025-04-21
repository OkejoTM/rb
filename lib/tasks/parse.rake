namespace :parse do
  task run: :environment do
    next unless PropimoSettings.on?('parser')

    begin
      PropimoSettings.set('parser', false) # Защищаем таску от параллельного запуска

      # links = %w(https://prian.ru/company/vipcon-lkv.html)
      # links = %w(https://prian.ru/company/first-class-homes.html)
      # links = %w(https://prian.ru/company/tolerance.html)
      # links = %w(https://prian.ru/company/dem-group-gmbh.html)
      # links = %w(https://imperof.com)
      # links = %w(http://israelhome.ru/)
      # links = %w(https://tools.grekodom.com/userfiles/realtyxml/grekodomyandexru.xml)
      # links = %w(https://www.czech-estate.cz/export/propimo.com/estate_xml.php)
      # links = %w(https://xml.afy.ru/xml/export/user/4/4d/4d6bb429b5663ea2890a08d92fea2bf5.xml)
      # links = %w(https://www.elgrekorealestate.com/property/movexml/)
      # links = %w(https://media.egorealestate.com/XML/peproperties_5118.xml)
      links = Agency.has_contract.select(:parse_source).map { |ag| ag.parse_source }

      Parser::WebParser.new.parse_links(links)
    ensure
      PropimoSettings.set('parser', true)
    end
  end
end

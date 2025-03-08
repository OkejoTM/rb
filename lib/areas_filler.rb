require 'csv'

class AreasFiller

  class << self


    def fill_geonames

      sql = ActiveRecord::Base.connection()

      sql.execute("
        START TRANSACTION;
        drop table if exists AN_cities;
        drop table if exists SA_cities;
        drop table if exists NA_cities;
        drop table if exists EU_cities;
        drop table if exists AS_cities;
        drop table if exists OC_cities;
        drop table if exists AF_cities;
        drop function if exists partition_for_cities() CASCADE;

        create table AN_cities() inherits (cities);
        alter table AN_cities add constraint partition_check check (continent = 'AN');

        create table SA_cities() inherits (cities);
        alter table SA_cities add constraint partition_check check (continent = 'SA');

        create table NA_cities() inherits (cities);
        alter table NA_cities add constraint partition_check check (continent = 'NA');

        create table AS_cities() inherits (cities);
        alter table AS_cities add constraint partition_check check (continent = 'AS');

        create table EU_cities() inherits (cities);
        alter table EU_cities add constraint partition_check check (continent = 'EU');

        create table AF_cities() inherits (cities);
        alter table AF_cities add constraint partition_check check (continent = 'AF');

        create table OC_cities() inherits (cities);
        alter table OC_cities add constraint partition_check check (continent = 'OC');");

      sql.execute("create function partition_for_cities() returns trigger as $$
        DECLARE
            v_parition_name text;
        BEGIN
            v_parition_name := format( '%s_cities', NEW.continent);
            execute 'INSERT INTO ' || v_parition_name || ' VALUES ( ($1).* )' USING NEW;
            return NULL;
        END;
        $$ language plpgsql;

        create trigger partition_cities before insert on cities for each row execute procedure partition_for_cities();
        COMMIT;");


      sql.execute("
        START TRANSACTION;
        drop table if exists AN_alternate_names;
        drop table if exists SA_alternate_names;
        drop table if exists NA_alternate_names;
        drop table if exists EU_alternate_names;
        drop table if exists AS_alternate_names;
        drop table if exists OC_alternate_names;
        drop table if exists AF_alternate_names;
        drop function if exists partition_for_alternate_names() CASCADE;

        create table AN_alternate_names() inherits (alternate_names);
        alter table AN_alternate_names add constraint partition_check_an check (continent = 'AN');

        create table SA_alternate_names() inherits (alternate_names);
        alter table SA_alternate_names add constraint partition_check_an check (continent = 'SA');

        create table NA_alternate_names() inherits (alternate_names);
        alter table NA_alternate_names add constraint partition_check_an check (continent = 'NA');

        create table AS_alternate_names() inherits (alternate_names);
        alter table AS_alternate_names add constraint partition_check_an check (continent = 'AS');

        create table EU_alternate_names() inherits (alternate_names);
        alter table EU_alternate_names add constraint partition_check_an check (continent = 'EU');

        create table AF_alternate_names() inherits (alternate_names);
        alter table AF_alternate_names add constraint partition_check_an check (continent = 'AF');

        create table OC_alternate_names() inherits (alternate_names);
        alter table OC_alternate_names add constraint partition_check_an check (continent = 'OC');");

      sql.execute("create function partition_for_alternate_names() returns trigger as $$
        DECLARE
            v_parition_name text;
        BEGIN
            v_parition_name := format( '%s_alternate_names', NEW.continent);
            execute 'INSERT INTO ' || v_parition_name || ' VALUES ( ($1).* )' USING NEW;
            return NULL;
        END;
        $$ language plpgsql;

        create trigger partition_alternate_names before insert on alternate_names for each row execute procedure partition_for_alternate_names();
        COMMIT;");

      City.destroy_all
      Region.destroy_all
      Country.destroy_all
      AlternateName.destroy_all

      @urls = {}
      fill_country_info
      fill_geoname
      indexingCities
      @urls.clear
      fill_iso_language_codes
      fill_alternateNames


    end

    def indexingCities
      sql = ActiveRecord::Base.connection()
      sql.execute("
      UPDATE cities
      SET region_id = (SELECT id FROM regions WHERE cities.admin1 = regions.admin1 AND cities.country_id = regions.country_id),
          country_id = NULL
      ;")
    end

    def deleteExtraAlternateNames
      sql = ActiveRecord::Base.connection()
      sql.execute("
      DELETE FROM alt_names WHERE ((SELECT COUNT(*) FROM countries  WHERE id = alt_names.geoname_id) = 0 AND
                                   (SELECT COUNT(*) FROM regions WHERE id = alt_names.geoname_id) = 0 AND
                                   (SELECT COUNT(*) FROM cities WHERE id = alt_names.geoname_id) = 0) ;")
    end

    def fill_country_info
      Rails.logger.debug "Parse countryInfo started\n"
      text = File.read(ENV['PWD'] + '/lib/geonames/countryInfo-n.txt')
      text.each_line do |line|
        s = line.chomp.split("\t")
        # [0] iso_alpha2
        # [1] iso_alpha3
        # [2] iso_numeric
        # [3] fips_code
        # [4] name
        # [5] capital
        # [6] areainsqkm
        # [7] population
        # [8] continent
        # [9] tld
        # [10] currencycode
        # [11] currencyname
        # [12] phone
        # [13] postalcode
        # [14] postalcoderegex
        # [15] languages
        # [16] geonameid
        # [17] neighbors
        # [18] equivfipscode
        country = Country.new
        country.id = s[16]
        country.iso_alpha2 = s[0]
        country.name = s[4]
        country.capital = s[5]
        country.continent = s[8]
        country.currencycode = s[10]
        country.currencyname = s[11]
        country.languages = s[15]
        country.save
      end
      Rails.logger.debug "Parse countryInfo finished\n"
    end

    def fill_geoname
      Rails.logger.debug "Parse geonames\n"
      text = File.open(ENV['PWD'] + '/lib/geonames/allCountries.txt')
      text.each_line.with_index do |line, index|
        s = line.chomp.split("\t")
        iteration = 100000
        Rails.logger.debug { "--- >Geonames #{(index + 1) / iteration} * #{iteration}" } if (index + 1) % iteration == 0
        Rails.logger.debug Time.now   if (index + 1) % iteration == 0
        # [0] geonameid         : integer id of record in geonames database
        # [1] name              : name of geographical point (utf8) varchar(200)
        # [2] asciiname         : name of geographical point in plain ascii characters, varchar(200)
        # [3] alternatenames    : alternatenames, comma separated varchar(4000)
        # [4] latitude          : latitude in decimal degrees (wgs84)
        # [5] longitude         : longitude in decimal degrees (wgs84)
        # [6] feature class     : see http://www.geonames.org/export/codes.html, char(1)
        # [7] feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
        # [8] country code      : ISO-3166 2-letter country code, 2 characters
        # [9] cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
        # [10] admin1 code       : fipscode (subject to change to iso code), isocode for the us and ch, see file admin1Codes.txt for display names of this code; varchar(20)
        # [11] admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80)
        # [12] admin3 code       : code for third level administrative division, varchar(20)
        # [13] admin4 code       : code for fourth level administrative division, varchar(20)
        # [14] population        : integer
        # [15] elevation         : in meters, integer
        # [16] gtopo30           : average elevation of 30'x30' (ca 900mx900m) area in meters, integer
        # [17] timezone          : the timezone id (see file timeZone.txt)
        # [18] modification date : date of last modification in yyyy-MM-dd format

        if (Country.exists? (s[0])) then
          country = Country.find(s[0]);
          country.name = s[1];
          country.asciiname = s[2];
          country.latitude = s[4];
          country.longitude = s[5];
          if (@urls.has_key?(s[2]))
            @urls[s[2]] += 1;
          else
            @urls[s[2]] = 0;
          end
          #@urls[i] = s[2]
          country.slug = s[2].parameterize
          #i += 1
          country.save
        elsif ((s[7] == 'ADM1') && (s[6] == 'A')) then
          region = Region.new
          if (Country.find_by(iso_alpha2: s[8]) != nil) then
            region.country_id = Country.find_by(iso_alpha2: s[8]).id;
          else
            Rails.logger.debug "No country " + s[8]
            Rails.logger.debug " for region " + s[0]
          end

          region.id = s[0];
          if (s[0] == 3573198)
            region.name = "Municipality-" + s[1];
            region.asciiname = "Municipality-" + s[2];
          else
            region.name = s[1];
            region.asciiname = s[2];
          end
          region.latitude = s[4];
          region.longitude = s[5];
          region.admin1 = s[10];
          if (@urls.has_key?(s[2]))
            @urls[s[2]] += 1;
          else
            @urls[s[2]] = 0;
          end
          #@urls[i] = s[2]
          region.slug = s[2].parameterize
          #i += 1
          region.save
        elsif (s[6] == 'P') then
          city = City.new
          city.id = s[0];

          if (Country.find_by(iso_alpha2: s[8]) != nil)
            city.country_id = Country.find_by(iso_alpha2: s[8]).id
            city.continent = Country.find_by(iso_alpha2: s[8]).continent
          else
            Rails.logger.debug "Line:" + line
            Rails.logger.debug "No country " + s.to_s
            Rails.logger.debug " for city " + s[0]
            Rails.logger.debug "country is nil? " + s[8].nil?.to_s
          end

          city.name = s[1]
          city.asciiname = s[2]
          city.latitude = s[4]
          city.longitude = s[5]
          city.fcode = s[7]
          city.admin1 = s[10]
          city.admin2 = s[11]
          city.admin3 = s[12]
          city.admin4 = s[13]
          seat = "city-"
          case s[7]
            when %w(PPLA4 PPLA3 PPLA2 PPLA)
              seat = "administrative-city-"
            when 'PPLC'
              seat = "capital-"
            when 'PPLF'
              seat = "village-"
            when %w(PPLH PPLW)
              seat = "historical-place-"
            when %w(PPL PPLL PPLQ PPLX)
              seat = "city-"
            when 'STLMT'
              seat = "settlement-"
          end

          if (@urls.has_key?(seat + s[2]))
            @urls[seat + s[2]] += 1;
          else
            @urls[seat + s[2]] = 1;
          end
          #@urls[i] = seat + s[2]

          ccount = @urls[seat + s[2]]
          tail_url = ccount == 1 ? "" : "-" + ccount.to_s
          city.slug = (seat + s[2] + tail_url).parameterize
          #i += 1
          if city.continent.present?
            city.save
          end

        end
      end
      Rails.logger.debug "Parse geoname finished\n"

    end



    def fill_alternateNames
      Rails.logger.debug "Parse alternateNames started\n"
      text = File.open(ENV['PWD'] + '/lib/geonames/alternateNames.txt')

      acceptIdsNA = Set.new
      acceptIdsSA = Set.new
      acceptIdsAF = Set.new
      acceptIdsEU = Set.new
      acceptIdsOC = Set.new
      acceptIdsAS = Set.new
      acceptIdsNA.merge(Country.where(continent: 'NA').ids.map(&:to_s))
      acceptIdsNA.merge(City.where(continent: 'NA').ids.map(&:to_s))

      acceptIdsSA.merge(Country.where(continent: 'SA').ids.map(&:to_s))
      acceptIdsSA.merge(City.where(continent: 'SA').ids.map(&:to_s))

      acceptIdsAF.merge(Country.where(continent: 'AF').ids.map(&:to_s))
      acceptIdsAF.merge(City.where(continent: 'AF').ids.map(&:to_s))

      acceptIdsEU.merge(Country.where(continent: 'EU').ids.map(&:to_s))
      acceptIdsEU.merge(City.where(continent: 'EU').ids.map(&:to_s))

      acceptIdsAS.merge(Country.where(continent: 'AS').ids.map(&:to_s))
      acceptIdsAS.merge(City.where(continent: 'AS').ids.map(&:to_s))

      acceptIdsOC.merge(Country.where(continent: 'OC').ids.map(&:to_s))

      Region.all.each do |reg|
        case reg.country.continent
          when 'OC'
            acceptIdsOC << reg.id.to_s
          when 'NA'
            acceptIdsNA << reg.id.to_s
          when 'AF'
            acceptIdsAF << reg.id.to_s
          when 'SA'
            acceptIdsSA << reg.id.to_s
          when 'EU'
            acceptIdsEU << reg.id.to_s
          when 'AS'
            acceptIdsAS << reg.id.to_s
        end
      end
      acceptIdsOC.merge(City.where(continent: 'OC').ids.map(&:to_s))

      Rails.logger.debug Time.now
      text.each_line.with_index do |line, index|
        iteration = 100000
        Rails.logger.debug { "--- >Alternate name (#{AlternateName.count}) for #{(index + 1) / iteration} * #{iteration}" } if (index + 1) % iteration == 0
        Rails.logger.debug Time.now   if (index + 1) % iteration == 0
        s = line.chomp.split("\t")
        if s[2] != 'link' &&
            #acceptIds.include?(s[1]) &&
            (search_by_iso_639_1(s[2]) != nil || search_by_iso_639_3(s[2]) != nil)

          # [1] geonameid
          # [2] isolanguage
          # [3] alternatename
          # [4] ispreferredname
          # [4] ispreferredname
          # [5] isshortname
          # [6] iscolloquial
          # [7] ishistoric

          alernateName = AlternateName.new
          if acceptIdsNA.include?(s[1])
            alernateName.continent = 'NA'
          elsif acceptIdsAF.include?(s[1])
            alernateName.continent = 'AF'
          elsif acceptIdsEU.include?(s[1])
            alernateName.continent = 'EU'
          elsif acceptIdsSA.include?(s[1])
            alernateName.continent = 'SA'
          elsif acceptIdsOC.include?(s[1])
            alernateName.continent = 'OC'
          elsif acceptIdsAS.include?(s[1])
            alernateName.continent = 'AS'
          end
=begin

          alernateName = AlternateName.new
          alernateName.continent = Country.find_by_id(s[1])&.continent
          alernateName.continent ||= Region.find_by_id(s[1])&.country&.continent
          alernateName.continent ||= City.find_by_id(s[1])&.continent
=end

          if (alernateName.continent.present?)
            alernateName.geoname_id = s[1]
            if (search_by_iso_639_1(s[2]) != nil)
              alernateName.iso_language = search_by_iso_639_1(s[2])
            elsif  (search_by_iso_639_3(s[2]) != nil)
              alernateName.iso_language = search_by_iso_639_3(s[2])
            end
            alernateName.alternate_name = s[3]
            alernateName.save
          end
        end
      end
      alernateName = AlternateName.new
      alernateName.continent = 'AS'
      alernateName.iso_language = 'Russian'
      alernateName.geoname_id = '1599049'
      alernateName.alternate_name = 'Паттайя'
      alernateName.save
      alernateName = AlternateName.new
      alernateName.continent = 'AS'
      alernateName.iso_language = 'English'
      alernateName.geoname_id = '1599049'
      alernateName.alternate_name = 'Phatthaya'
      alernateName.save
      Rails.logger.debug "Parse alternateNames finished\n"
    end

    def fill_iso_language_codes
      i = 0
      @isoLanguageCode = []
      Rails.logger.debug "Parse iso_language_codes started\n"
      text = File.read(ENV['PWD'] + '/lib/geonames/iso-languagecodes.txt')
      text.each_line do |line|
        s = line.chomp.split("\t")
        # [0] iso_639_3
        # [1] iso_639_2
        # [2] iso_639_1
        # [3] language_name
        @isoLanguageCode[i] = s
        i += 1
      end
      Rails.logger.debug "Parse iso_language_codes finished\n"
    end

    def search_by_iso_639_1 (str)
      @isoLanguageCode.each do |iso|
        if iso[2] == str
          return iso[3]
        end
      end
      return nil
    end

    def search_by_iso_639_3 (str)
      @isoLanguageCode.each do |iso|
        if iso[0] == str
          return iso[3]
        end
      end
      return nil
    end

  end
end

namespace :property do
  desc "Этот метод привязывает недвижимость к локации"
  task fill_location: [ :environment ] do
    pcount = Property.where("region_id IS NULL AND city_id IS NULL").count

    p "Start fill location"
    p Time.now

    @timeFindCountry = 0
    @timeFindCountry_name = 0
    @timeFindCountry_altername = 0
    @timeFindCity = 0
    @timeFindCity_name = 0
    @timeFindCity_altername = 0
    @timeFindRegion = 0
    @timeFindRegion_name = 0
    @timeFindCity_without_region = 0
    @timeFindRegion_altername = 0
    spain_id = 2510769
    spainListAlicante = ['Costa Blanca', 'Orihuela Costa']
    spainListAndalucia = ['Costa del Sol']
    spainListGirona = ["Costa Brava", "Platja D'Aro"]
    spainListBarcelona = ['Costa del Maresme']

    foundedCities = Set.new
    foundedRegions = Set.new

    foundedCountries = Set.new

    @citylist = Set.new
    @citylist.merge(City.select('id', 'name', 'asciiname', 'longitude', 'latitude', 'region_id', 'country_id').where(continent: 'EU').all.to_set)

    greece_id = 390903
    greeceListCentralMacedonia = ['Pieria', 'Sithonia']
    Property.where("region_id IS NULL AND city_id IS NULL").each_with_index do |prop, index|

      iteration = 100
      p "--- >Fill location for property #{(index + 1) / iteration} * #{iteration} from #{pcount}" if (index + 1) % iteration == 0
      p Time.now   if (index + 1) % iteration == 0
      p @timeFindCountry  if (index + 1) % iteration == 0
      p @timeFindCountry_name   if (index + 1) % iteration == 0
      p @timeFindCountry_altername   if (index + 1) % iteration == 0
      p @timeFindRegion   if (index + 1) % iteration == 0
      p @timeFindRegion_name   if (index + 1) % iteration == 0
      p @timeFindRegion_altername   if (index + 1) % iteration == 0
      p @timeFindCity   if (index + 1) % iteration == 0
      p @timeFindCity_without_region if (index + 1) % iteration == 0
      p @timeFindCity_name   if (index + 1) % iteration == 0
      p @timeFindCity_altername   if (index + 1) % iteration == 0

      timebuff = Time.now
      foundCountry = contains_in_founded_countries(foundedCountries, prop.country_name_en, prop.country_name_ru)
      if foundCountry.present?
        country = Country.find(foundCountry)
      else
        if prop.country_name_en == "USA" || prop.country_name_ru == "USA"
          country ||= Country.find(6252001)
        end
        if prop.country_name_en == "UAE" || prop.country_name_ru == "UAE"
          country ||= Country.find(290557)
        end
        #Ищем в именах
        country ||= Country.find_by(name: prop.country_name_en&.gsub("'", "''"))
        country ||= Country.find_by(asciiname: prop.country_name_en&.gsub("'", "''"))

        @timeFindCountry_name += Time.now - timebuff
        timebuff_2 = Time.now

        #Ищем в альтернативных именых
        alternateNameArray = find_array_of_alternames(country, prop.country_name_en)
        country ||= find_country_by_alternate_name_array(alternateNameArray, prop)

        alternateNameArray = find_array_of_alternames(country, prop.country_name_ru)
        country ||= find_country_by_alternate_name_array(alternateNameArray, prop)

        @timeFindCountry_altername += Time.now - timebuff_2

        @timeFindCountry += Time.now - timebuff
      end
      continent = country&.continent
      prop.country_id = country&.id
      if prop.country_id.present?

        foundedCountries.add([prop.country_id, prop.country_name_en, prop.country_name_ru])

        if (prop.region_name_ru&.include?("(region)"))
          prop.region_name_ru = prop.region_name_ru.gsub("(region)", "")
        end
        if (prop.region_name_ru&.include?("(area)"))
          prop.region_name_ru = prop.region_name_ru.gsub("(area)", "")
        end
        if (prop.region_name_ru&.include?("()"))
          prop.region_name_ru = prop.region_name_ru.gsub("()", "")
        end

        while prop.region_name_ru&.chomp(' ') != prop.region_name_ru
          prop.region_name_ru = prop.region_name_ru.chomp(' ')
        end

        if (prop.region_name_en&.include?("(region)"))
          prop.region_name_en = prop.region_name_en.gsub("(region)", "")
        end
        if (prop.region_name_en&.include?("(area)"))
          prop.region_name_en = prop.region_name_en.gsub("(area)", "")
        end
        if (prop.region_name_en&.include?("()"))
          prop.region_name_en = prop.region_name_en.gsub("()", "")
        end

        while prop.region_name_en&.chomp(' ') != prop.region_name_en
          prop.region_name_en = prop.region_name_en.chomp(' ')
        end

        if (spainListAlicante.include?(prop.city_name_en) || spainListAlicante.include?(prop.city_name_ru) ||
            spainListAlicante.include?(prop.region_name_en) || spainListAlicante.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Alicante', 2593113)
          prop.city_id = 2521978
        elsif (spainListBarcelona.include?(prop.city_name_en) || spainListBarcelona.include?(prop.city_name_ru) ||
            spainListBarcelona.include?(prop.region_name_en) || spainListBarcelona.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Barcelona', 3336901)
          prop.city_id = 3128760
        elsif (spainListGirona.include?(prop.city_name_en) || spainListGirona.include?(prop.city_name_ru) ||
            spainListGirona.include?(prop.region_name_en) || spainListGirona.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Girona', 3336901)
          prop.city_id = 3121456
        elsif (spainListAndalucia.include?(prop.city_name_en) || spainListAndalucia.include?(prop.city_name_ru) ||
            spainListAndalucia.include?(prop.region_name_en) || spainListAndalucia.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #region = Region.find_by_asciiname_and_country_id( 'Andalucia', 3336901)
          prop.region_id = 2593109
        elsif (greeceListCentralMacedonia.include?(prop.city_name_en) || greeceListCentralMacedonia.include?(prop.city_name_ru) ||
            greeceListCentralMacedonia.include?(prop.region_name_en) || greeceListCentralMacedonia.include?(prop.region_name_ru)) && prop.country_id == greece_id
          #region = Region.find_by_asciiname_and_country_id( 'Central Macedonia', greece_id)
          prop.region_id = 6697801
        elsif prop.country_id == spain_id && (prop.city_name_en == 'Alfas del Pi' || prop.city_name_ru == 'Alfas del Pi' ||
            prop.region_name_en == 'Alfas del Pi' || prop.region_name_ru == 'Alfas del Pi')
          #City.find_by_continent_and_asciiname_and_region_id(continent, "l'Alfas del Pi", 2593113)
          prop.city_name_en = "l'Alfas del Pi"
          prop.city_id = 6559503
        elsif prop.hs_link.present? && (prop.region_name_en.present? || prop.region_name_ru.present?)
          founded = contains_in_founded(foundedRegions, prop.country_id, prop.region_name_en, prop.region_name_ru)
          if founded.present? && LocationDistance.nearly?(Region.find(founded), prop, 10)
            prop.region_id = founded
          else
            timebuff = Time.now
            #ищем в названиях
            region = Region.find_by(name: prop.region_name_en&.gsub("'", "''"), country_id: prop.country_id)
            region ||= Region.find_by(asciiname: prop.region_name_en&.gsub("'", "''"), country_id: prop.country_id)
            @timeFindRegion_name += Time.now - timebuff

            timebuff_2 = Time.now
            #Ищем в альтернативных именах
            alternateNameArray = find_array_of_alternames_by_continent(region, prop.region_name_en, continent)
            region ||= find_region_by_alternate_name_array(prop, alternateNameArray)

            alternateNameArray = find_array_of_alternames_by_continent(region, prop.region_name_ru, continent)
            region ||= find_region_by_alternate_name_array(prop, alternateNameArray)
            @timeFindRegion_altername += Time.now - timebuff_2

            @timeFindRegion += Time.now - timebuff
          end
        end
        if prop.city_id.blank? && !changed_region_to_city(prop)
          founded = contains_in_founded(foundedCities, prop.country_id, prop.city_name_en, prop.city_name_ru)
          if founded.present? && LocationDistance.nearly?(City.find(founded), prop, 2)
            prop.city_id = founded
          else
            timebuff = Time.now
            #Если нашелся регион
            if region.present?
              prop.region_id = region.id
            end

            city ||= find_city(prop, continent)
            @timeFindCity_name += Time.now - timebuff

            timebuff_2 = Time.now
            #Ищем в альтернативных именах
            alternateNameArray = find_array_of_alternames_by_continent(city, prop.city_name_en, 'EU')
            city ||= find_city_by_alternate_name_array(prop, alternateNameArray)

            alternateNameArray = find_array_of_alternames_by_continent(city, prop.city_name_ru, 'EU')
            city ||= find_city_by_alternate_name_array(prop, alternateNameArray)

            @timeFindCity_altername += Time.now - timebuff_2
            @timeFindCity += Time.now - timebuff
            prop.city_id = city&.id
          end
        end

      else
        if prop.country_name_en.nil? && prop.country_name_ru.nil?
          p "WARNING!!! Nil country for " + (prop.external_link).to_s
        else
          p "WARNING!!! No country " + (prop.country_name_en.presence).to_s +
                " or " + (prop.country_name_ru.presence).to_s +
                " in tables for " + (prop.external_link).to_s
        end
      end
      #changed_city_to_region(prop, continent);
      if prop.region_id.blank? && prop.city_id.blank?
        p "WARNING!!! No location for property " + (prop.external_link).to_s
      else
        if (foundedCities.count > 20000)
          foundedCities.clear
        end

        if prop.city_id.present?
          foundedCities.add([prop.country_id, prop.city_name_en, prop.city_name_ru, prop.city_id])
        end
        if prop.region_id.present?
          foundedRegions.add([prop.country_id, prop.region_name_en, prop.region_name_ru, prop.region_id])
        end
      end

      prop.save
    end
  end

  task fill_location_second_iteration: [ :environment ] do
    pcount = Property.where("region_id IS NULL AND city_id IS NULL").count

    p "Start fill location"
    p Time.now

    @timeFindCountry = 0
    @timeFindCountry_name = 0
    @timeFindCountry_altername = 0
    @timeFindCity = 0
    @timeFindCity_name = 0
    @timeFindCity_altername = 0
    @timeFindRegion = 0
    @timeFindRegion_name = 0
    @timeFindCity_without_region = 0
    @timeFindRegion_altername = 0
    spain_id = 2510769
    spainListAlicante = ['Costa Blanca', 'Orihuela Costa']
    spainListAndalucia = ['Costa del Sol']
    spainListGirona = ["Costa Brava", "Platja D'Aro"]
    spainListBarcelona = ['Costa del Maresme']

    foundedCities = Set.new
    foundedRegions = Set.new
    foundedCountries = Set.new

    @citylist = Set.new
    @citylist.merge(City.select('id', 'name', 'asciiname', 'longitude', 'latitude', 'region_id', 'country_id').where(continent: 'EU').all.to_set)


    greece_id = 390903
    greeceListCentralMacedonia = ['Pieria', 'Sithonia']
    Property.where("region_id IS NULL AND city_id IS NULL").each_with_index do |prop, index|

      iteration = 100
      p "--- >Fill location for property #{(index + 1) / iteration} * #{iteration} from #{pcount}" if (index + 1) % iteration == 0
      p Time.now   if (index + 1) % iteration == 0
      p @timeFindCountry  if (index + 1) % iteration == 0
      p @timeFindCountry_name   if (index + 1) % iteration == 0
      p @timeFindCountry_altername   if (index + 1) % iteration == 0
      p @timeFindCity   if (index + 1) % iteration == 0
      p @timeFindCity_without_region if (index + 1) % iteration == 0
      p @timeFindCity_name   if (index + 1) % iteration == 0
      p @timeFindCity_altername   if (index + 1) % iteration == 0


      timebuff = Time.now
      foundCountry = contains_in_founded_countries(foundedCountries, prop.country_name_en, prop.country_name_ru)
      if foundCountry.present?
        country = Country.find(foundCountry)
      else
        if prop.country_name_en == "USA" || prop.country_name_ru == "USA"
          country ||= Country.find(6252001)
        end
        if prop.country_name_en == "UAE" || prop.country_name_ru == "UAE"
          country ||= Country.find(290557)
        end
        if prop.country_name_en.present?
          #Ищем в именах
          country ||= Country.find_by(name: prop.country_name_en&.gsub("'", "''"))
          country ||= Country.find_by(asciiname: prop.country_name_en&.gsub("'", "''"))
        elsif prop.hs_link.present?
          country ||= Country.find_by(name: prop.country_name_ru&.gsub("'", "''"))
          country ||= Country.find_by(asciiname: prop.country_name_ru&.gsub("'", "''"))
        end


        @timeFindCountry_name += Time.now - timebuff
        timebuff_2 = Time.now

        if prop.country_name_en.present?
          #Ищем в альтернативных именых
          alternateNameArray = find_array_of_alternames(country, prop.country_name_en)
          country ||= find_country_by_alternate_name_array(alternateNameArray, prop)
        end


        if prop.country_name_ru.present?
          alternateNameArray = find_array_of_alternames(country, prop.country_name_ru)
          country ||= find_country_by_alternate_name_array(alternateNameArray, prop)
        end


        @timeFindCountry_altername += Time.now - timebuff_2

        @timeFindCountry += Time.now - timebuff
      end
      continent = country&.continent
      prop.country_id = country&.id

      if prop.country_id.present?

        foundedCountries.add([prop.country_id, prop.country_name_en, prop.country_name_ru])

        if (spainListAlicante.include?(prop.city_name_en) || spainListAlicante.include?(prop.city_name_ru) ||
            spainListAlicante.include?(prop.region_name_en) || spainListAlicante.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Alicante', 2593113)
          prop.city_id = 2521978
        elsif (spainListBarcelona.include?(prop.city_name_en) || spainListBarcelona.include?(prop.city_name_ru) ||
            spainListBarcelona.include?(prop.region_name_en) || spainListBarcelona.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Barcelona', 3336901)
          prop.city_id = 3128760
        elsif (spainListGirona.include?(prop.city_name_en) || spainListGirona.include?(prop.city_name_ru) ||
            spainListGirona.include?(prop.region_name_en) || spainListGirona.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #city = City.find_by_continent_and_name_and_region_id(continent, 'Girona', 3336901)
          prop.city_id = 3121456
        elsif (spainListAndalucia.include?(prop.city_name_en) || spainListAndalucia.include?(prop.city_name_ru) ||
            spainListAndalucia.include?(prop.region_name_en) || spainListAndalucia.include?(prop.region_name_ru)) && prop.country_id == spain_id
          #region = Region.find_by_asciiname_and_country_id( 'Andalucia', 3336901)
          prop.region_id = 2593109
        elsif (greeceListCentralMacedonia.include?(prop.city_name_en) || greeceListCentralMacedonia.include?(prop.city_name_ru) ||
            greeceListCentralMacedonia.include?(prop.region_name_en) || greeceListCentralMacedonia.include?(prop.region_name_ru)) && prop.country_id == greece_id
          #region = Region.find_by_asciiname_and_country_id( 'Central Macedonia', greece_id)
          prop.region_id = 6697801
        elsif prop.country_id == spain_id && (prop.city_name_en == 'Alfas del Pi' || prop.city_name_ru == 'Alfas del Pi' ||
            prop.region_name_en == 'Alfas del Pi' || prop.region_name_ru == 'Alfas del Pi')
          #City.find_by_continent_and_asciiname_and_region_id(continent, "l'Alfas del Pi", 2593113)
          prop.city_name_en = "l'Alfas del Pi"
          prop.city_id = 6559503
        else

          founded = contains_in_founded(foundedRegions, prop.country_id, prop.region_name_en, prop.region_name_ru)
          if founded.present? && LocationDistance.nearly?(Region.find(founded), prop, 10)
            prop.region_id = founded
          end

          founded = contains_in_founded(foundedCities, prop.country_id, prop.city_name_en, prop.city_name_ru)
          if founded.present? && LocationDistance.nearly?(City.find(founded), prop, 2)
            prop.city_id = founded
          end

          if (prop.region_name_ru&.include?("region"))
            prop.region_name_ru = prop.region_name_ru.gsub("region", "");
          end

          changed_city_to_region(prop, continent);
        end
      end

      if (prop.region_id.blank? && prop.city_id.blank?)
        # p "WARNING!!! No location for property " + (prop.external_link).to_s
      else
        if (foundedCities.count > 20000)
          foundedCities.clear
        end
        if prop.city_id.present?
          foundedCities.add([prop.country_id, prop.city_name_en, prop.city_name_ru, prop.city_id])
        end
        if prop.region_id.present?
          foundedRegions.add([prop.country_id, prop.region_name_en, prop.region_name_ru, prop.region_id])
        end
      end

      prop.save
    end
  end

  def contains_in_founded_countries(founded, name_en, name_ru)
    founded.each do |f|
      if f[1] == name_en && f[2] == name_ru
        return f[0]
      end
    end
    nil
  end

  def contains_in_founded(founded, country_id, name_en, name_ru)
    founded.each do |f|
      if f[0] == country_id && f[1] == name_en && f[2] == name_ru
        return f[3]
      end
    end
    nil
  end

  def find_one_city_in_citylist (arg)
    @citylist.each do |cityItem|
      condition = true
      if arg[:country_id].present?
        condition &&= arg[:country_id] == cityItem.country_id
      end
      if condition && arg[:region_id].present?
        condition &&= arg[:region_id] == cityItem.region_id
      end
      if condition && arg[:asciiname].present?
        condition &&= arg[:asciiname] == cityItem.asciiname
      end
      if condition && arg[:name].present?
        condition &&= arg[:name] == cityItem.name
      end
      if condition
        return cityItem
      end
    end
    return nil
  end

  def find_all_cities_in_citylist (arg)
    cities = Set.new
    @citylist.each do |cityItem|
      condition = true
      if arg[:country_id].present?
        condition &&= arg[:country_id] == cityItem.country_id
      end
      if condition && arg[:region_id].present?
        condition &&= arg[:region_id] == cityItem.region_id
      end
      if condition && arg[:asciiname].present?
        condition &&= arg[:asciiname] == cityItem.asciiname
      end
      if condition && arg[:name].present?
        condition &&= arg[:name] == cityItem.name
      end
      if condition
        cities.add(cityItem)
      end
    end
    return cities
  end

  #Находит город в Европе
  def find_city_from_EU(property)

    #Если нашелся регион
    if property.region_id.present?

      #Есть и имя  регион
      city ||= find_one_city_in_citylist(name: property.city_name_en&.gsub("'", "''"), region_id: property.region_id)
      city ||= find_one_city_in_citylist(asciiname: property.city_name_en&.gsub("'", "''"), region_id: property.region_id)

    else
      #Есть имя и страна
      city ||= find_one_city_in_citylist(name: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)
      city ||= find_one_city_in_citylist(asciiname: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)

      #Есть имя и страна , но не распарсен регион (а он фактичеси есть)
      #Например когда Великобритания/Лондон, а могла быть Великобритания/Англия/Лондон
      timebuff_2 = Time.now
      ccc = Set.new
      if city.blank?
        ccc.merge(find_all_cities_in_citylist(name: property.city_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      ccc = Set.new
      if city.blank?
        ccc.merge(find_all_cities_in_citylist(asciiname: property.city_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      @timeFindCity_without_region += Time.now - timebuff_2
    end

    return city
  end

  #Находит горд
  def find_city(property, continent)
    if (continent == 'EU')
      return find_city_from_EU(property)
    end

    #Если нашелся регион
    if property.region_id.present?

      #Есть и имя  регион
      city ||= City.find_by(continent: continent, name: property.city_name_en&.gsub("'", "''"), region_id: property.region_id)
      city ||= City.find_by(continent: continent, asciiname: property.city_name_en&.gsub("'", "''"), region_id: property.region_id)

    else
      #Есть имя и страна
      city ||= City.find_by(continent: continent, name: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)
      city ||= City.find_by(continent: continent, asciiname: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)


      #Есть имя и страна , но не распарсен регион (а он фактичеси есть)
      #Например когда Великобритания/Лондон, а могла быть Великобритания/Англия/Лондон
      timebuff_2 = Time.now
      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(name: property.city_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(asciiname: property.city_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      @timeFindCity_without_region += Time.now - timebuff_2
    end
    return city
  end

  #Находит альтернативные имена
  def find_array_of_alternames(location, name)
    alternateNameArray = Set.new
    if location.blank? && name.present?
      alternateNameArray.merge(AlternateName.select("geoname_id").where("alternate_name LIKE '%#{name.gsub("'", "''")}%'").to_set)
    end
    return alternateNameArray
  end

  #Находит альтернативные имена
  def find_array_of_alternames_by_continent(location, name, continent)
    alternateNameArray = Set.new
    if location.blank? && name.present?
      alternateNameArray.merge(AlternateName.select("geoname_id").where(continent: continent).where("alternate_name LIKE '%#{name.gsub("'", "''")}%'").to_set)
    end
    return alternateNameArray
  end

  #Находит регион через имя города
  def changed_region_to_city(property)
    if property.region_name_en.present? && property.region_name_ru.present? &&
        property.city_name_en.blank? && property.city_name_ru.blank?
      return false;
    end
    #ищем в названиях
    region = Region.find_by(name: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)
    region ||= Region.find_by(asciiname: property.city_name_en&.gsub("'", "''"), country_id: property.country_id)

    #Ищем в альтернативных именах
    alternateNameArray = find_array_of_alternames(region, property.city_name_en)
    region ||= find_region_by_alternate_name_array(property, alternateNameArray)

    alternateNameArray = find_array_of_alternames(region, property.city_name_ru)
    region ||= find_region_by_alternate_name_array(property, alternateNameArray)

    property.region_id = region&.id

    return region.present?
  end

  #Находит город через имя региона
  def changed_city_to_region(property, continent)
    #только если регион еще не найдет
    if property.region_id.present?
      return false;
    end

    if property.region_name_en.blank? && property.region_name_ru.blank? &&
        property.city_name_en.present? && property.city_name_ru.present?
      return false;
    end
    timebuff = Time.now
    #Есть имя и страна
    if property.region_name_en.present?
      city ||= City.find_by(continent: continent, name: property.region_name_en&.gsub("'", "''"), country_id: property.country_id)
      city ||= City.find_by(continent: continent, asciiname: property.region_name_en&.gsub("'", "''"), country_id: property.country_id)
    elsif property.hs_link.present? && property.region_name_ru.present?
      city ||= City.find_by(continent: continent, name: property.region_name_ru&.gsub("'", "''"), country_id: property.country_id)
      city ||= City.find_by(continent: continent, asciiname: property.region_name_ru&.gsub("'", "''"), country_id: property.country_id)
    end

    #Есть имя и страна , но не распарсен регион (а он фактичеси есть)
    #Например когда Великобритания/Лондон, а могла быть Великобритания/Англия/Лондон

    timebuff_2 = Time.now
    if property.region_name_en.present?
      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(name: property.region_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(asciiname: property.region_name_en&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)
    elsif property.hs_link.present? && property.region_name_ru.present?
      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(name: property.region_name_ru&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)

      ccc = Set.new
      if city.blank?
        ccc.merge(City.where(continent: continent).where(asciiname: property.region_name_ru&.gsub("'", "''")).to_set)
      end
      city ||= find_city_without_region(ccc, property)
    end


    @timeFindCity_without_region += Time.now - timebuff_2

    timebuff_2 = Time.now
    if property.region_name_en.present?
      #Ищем в альтернативных именах
      alternateNameArray = find_array_of_alternames_by_continent(city, property.region_name_en, continent)
      city ||= find_city_by_alternate_name_array(property, alternateNameArray)
    end
    if property.region_name_ru.present?

      alternateNameArray = find_array_of_alternames_by_continent(city, property.region_name_ru, continent)
      city ||= find_city_by_alternate_name_array(property, alternateNameArray)
    end

    @timeFindCity_altername += Time.now - timebuff_2
    @timeFindCity += Time.now - timebuff

    property.city_id = city&.id
  end

  #Находит регион через массив альтернативных имен
  def find_region_by_alternate_name_array(property, alternateNameArray)
    results = {}
    alternateNameArray.each do |arr|
      #111km = 1 градус по широте

      rr = Region.find_by(id: arr.geoname_id)
      if rr.present? && rr.country_id == property.country_id
        if results.keys.exclude?(rr)
          results[rr] = LocationDistance.distance(rr, property)
        end
      end
    end
    return results.key(results.values.min)
  end

  #Находит город через массив альтернативных имен
  def find_city_by_alternate_name_array(property, alternateNameArray)
    alternateNameArray.each do |arr|
      city = City.find_by(id: arr.geoname_id)

      res_city = nil;
      #111km = 1 градус по широте
      if city.present? && property.region_id.present? && city.region_id == property.region_id
        res_city = city
      elsif city.present? && city.country_id == property.country_id
        res_city = city
      elsif city.present? &&
          city.region.present? &&
          property.country_id == city.region.country_id
        res_city = city
      elsif find_city_without_region([city], property)
        return find_city_without_region([city], property)
      end
      if res_city.present? && LocationDistance.nearly?(res_city, property, 2)
        return res_city
      end
    end
    return nil
  end

  #Находит город без указанного региона
  def find_city_without_region (city_array, property)
    # time_buff = Time.now
    city_array.each do |cc|
      if cc&.region&.country_id == property&.country_id &&
          LocationDistance.nearly?(cc, property, 1)
        property.region_id = cc.region_id
        return cc
      end
    end
    return nil
  end

  #Находит страну через массив альтернативных имен
  def find_country_by_alternate_name_array(alternateNameArray, property)
    # time_buff = Time.now
    results = {}
    alternateNameArray.each do |arr|
      #111km = 1 градус по широте
      cc = Country.find_by(id: arr.geoname_id)
      if cc.present?
        if results.keys.exclude?(cc)
          results[cc] = LocationDistance.distance(cc, property)
        end
      end
    end
    return results.key(results.values.min)
  end
end

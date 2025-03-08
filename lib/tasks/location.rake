namespace :location do
  task update_counters: :environment do
    countries_count = Country.where('properties_count > 0').count
    Country.where('properties_count > 0').each_with_index do |c, index|
      p "---Countries #{index + 1} of #{countries_count}" if index % 10 == 0
      c.update_counter_cache
    end

    regions_count = Region.where('properties_count > 0').count
    Region.where('properties_count > 0').each_with_index do |r, index|
      p "---Regions #{index + 1} of #{regions_count}" if index % 10 == 0
      r.update_counter_cache
    end

    cities_count = City.all.count
    City.all.each_with_index do |c, index|
      p "---Cities #{index + 1} of #{cities_count}" if index % 10 == 0
      if c.properties.count > 0 || c.properties_count > 0
        c.update_counter_cache
      end
    end
  end

  namespace :country do

    task update_agencies: :environment do
      countries_count = Country.visible.count
      Country.visible.each_with_index do |c, index|
        p "--- Country #{index + 1} of #{countries_count}" if index % 10 == 0

        agency_ids = Agency
                       .joins(:properties)
                       .where(properties: { country_id: c.id })
                       .distinct
                       .ids

        c.agencies.clear
        c.agency_ids = agency_ids

        active_agency_ids = Agency
                              .joins(:properties)
                              .where("properties.country_id = ? AND properties.is_active = true", c.id)
                              .distinct
                              .ids

        inactive_agency_ids = agency_ids - active_agency_ids

        if inactive_agency_ids.present?
          # Написал через Arel, но получилось громоздко и много объектов для простенького запроса
          # agencies_countries = Arel::Table.new(:agencies_countries)
          # update_ac = Arel::UpdateManager.new
          # update_ac.table(agencies_countries)
          # update_ac.where(agencies_countries[:agency_id]
          #                   .in(inactive_agency_ids)
          #                   .and(agencies_countries[:country_id]
          #                            .eq(c.id)))
          #           .set([
          #                    [agencies_countries[:is_active], false]
          #                ])
          #
          # ActiveRecord::Base.connection.execute(update_ac.to_sql)

          ActiveRecord::Base
            .connection
            .execute("UPDATE \"agencies_countries\"
                      SET \"is_active\" = false
                      WHERE \"agency_id\" IN (#{inactive_agency_ids.join(',')}) AND \"country_id\" = #{c.id}")
        end
      end
    end

  end


  namespace :region do

    task update_agencies: :environment do
      regions_count = Region.visible.count
      Region.visible.each_with_index do |c, index|
        p "--- Region #{index + 1} of #{regions_count}" if index % 10 == 0

        agency_ids = Agency.joins(:properties).where("properties.region_id = #{c.id}").distinct.ids

        c.agencies.clear
        c.agency_ids = agency_ids
      end
    end

  end


  namespace :city do

    task update_agencies: :environment do
      cities_count = City.visible.count
      City.visible.each_with_index do |c, index|
        p "--- City #{index + 1} of #{cities_count}" if index % 100 == 0

        agency_ids = Agency.joins(:properties).where("properties.city_id = #{c.id}").distinct.ids

        c.agencies.clear
        c.agency_ids = agency_ids
      end
    end

  end
end

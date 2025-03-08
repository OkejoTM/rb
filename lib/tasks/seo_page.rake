namespace :seo_page do
  task update_counters: :environment do
    seo_location_pages = SeoLocationPage.all.count
    SeoLocationPage.all.each_with_index do |slp, index|
      p "---Seo Location Page #{index + 1} of #{seo_location_pages}" if index % 10 == 0
      slp.update_properties_count
    end

    seo_agencies_pages = SeoAgenciesPage.all.count
    SeoAgenciesPage.all.each_with_index do |sap, index|
      p "---Seo Agencies Page #{index + 1} of #{seo_agencies_pages}" if index % 10 == 0
      sap.update_agencies_count
    end
  end
end

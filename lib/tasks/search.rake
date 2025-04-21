namespace :search do
  desc "Reindex active searchable records"
  task reindex_active: :environment do
    p Time.now
    p "--Reindex countries"
    Country.visible.reindex
    p "--Reindex regions"
    Region.visible.reindex
    p "--Reindex cities"
    City.visible.reindex
  end

  desc "Reindex all searchable records"
  task reindex_all: :environment do
    p Time.now
    p "--Reindex countries"
    Country.reindex
    p "--Reindex regions"
    Region.reindex
    p "--Reindex cities"
    City.reindex
  end
end

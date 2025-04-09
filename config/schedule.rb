# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# Use 'whenever --update-crontab' for update crontab

set :output, File.join(Whenever.path, "log", "cron.log")
#При необходимости  set :environment, "development"
set :environment, "production"

every :day do
  rake 'sitemap:refresh', environment: :production
  rake 'currency:update_rates', environment: :production
end

every :day, at: '1:00am' do
  rake "search:reindex_active"
  runner 'CarrierWave.clean_cached_files!(1.hour)', environment: :production
  runner 'Rails.cache.cleanup', environment: :production
end

every :day, at: '1:30am' do
  rake "location:country:update_agencies"
  rake "location:region:update_agencies"
  rake "location:city:update_agencies"
  #rake "pictures:clear_temporary"
end

every :day, at: '2:00am' do
  rake "seo_page:update_counters"
  rake 'parse_turkey:run'
end

every :saturday, at: '3:25pm' do
  rake "search:reindex_all"
  rake "vacuum:full"
end

every :day, at: '0:00am' do
  rake 'parse:run'
end

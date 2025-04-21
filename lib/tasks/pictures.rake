namespace :pictures do
  desc "Clear temporary pictures"
  task clear_temporary: :environment do
    Picture.temporary.destroy_all
  end
end

class Admin::PagesController < Admin::BasicAdminController
  init_resource :page
  define_actions :index, :edit, :update
end

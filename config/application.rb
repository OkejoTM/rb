require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Propimo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.available_locales = [:ru, :en]
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :ru
    config.time_zone = 'Moscow'
    config.filter_parameters << :pic

    config.use_webpack = true

    # TODO разобраться, источник: https://github.com/mileszs/wicked_pdf/issues/857
    AssetsConfig = Struct.new(:enabled, :compile, keyword_init: true)
    config.assets = AssetsConfig.new(enabled: false, compile: false)

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/lib/parser)
    config.autoload_paths << Rails.root.join('validators')

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib', 'pages')
    config.autoload_paths << Rails.root.join('lib', 'attributes')
    config.autoload_paths << Rails.root.join('lib', 'model_services')
    config.autoload_paths << Rails.root.join('lib', 'parsing_schemas')

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib', 'modules')

    config.active_job.queue_adapter = :sidekiq

    config.to_prepare do
      Devise::SessionsController.layout "frontend"
      Devise::RegistrationsController.layout "frontend"
      Devise::ConfirmationsController.layout "frontend"
      Devise::UnlocksController.layout "frontend"
      Devise::PasswordsController.layout "frontend"
    end
  end
end

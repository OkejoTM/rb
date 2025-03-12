class ApplicationJob < ActiveJob::Base
  cattr_accessor :logger,
                 default: ActiveSupport::TaggedLogging.new(Rails.logger) unless Rails.env.test?
end

# frozen_string_literal: true

# don't seed on tests environment
return if Rails.env.test?

# TODO: Remove me once this is released: https://github.com/rails/rails/pull/35905
ActiveSupport.on_load(:active_job) do
  ActiveJob::Base.queue_adapter = Rails.env.development? ? :inline : Rails.application.config.active_job.queue_adapter
end

base_path = File.expand_path("seeds", __dir__)
$LOAD_PATH.push base_path

Rails.logger = Logger.new(STDOUT)

require "census/seeds/scopes"
Census::Seeds::Scopes.new.seed base_path: "#{base_path}/scopes", logger: Rails.logger

unless Rails.env.production?
  ActionMailer::Base.delivery_method = :test

  require "faker"
  require "timecop"

  require "random"
  require "people"
  require "procedures"
  require "payments"
  require "cancellations"
end

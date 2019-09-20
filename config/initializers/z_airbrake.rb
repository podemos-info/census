# frozen_string_literal: true

Airbrake.configure do |config|
  config.environment = Rails.env
  config.ignore_environments = %w(test development)
  config.host = Settings.system.airbrake.host
  config.project_id = Settings.system.airbrake.project_id
  config.project_key = Settings.system.airbrake.api_key
  config.root_directory = Rails.root
  config.logger = Rails.logger
  config.blacklist_keys = Rails.application.config.filter_parameters
end

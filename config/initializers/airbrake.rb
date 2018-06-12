# frozen_string_literal: true

Airbrake.configure do |config|
  config.environment = Rails.env
  config.ignore_environments = %w(test development)
  config.host = Settings.system.airbrake.host
  config.project_id = Settings.system.airbrake.project_id
  config.project_key = Settings.system.airbrake.api_key
end

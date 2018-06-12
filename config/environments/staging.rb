# frozen_string_literal: true

require_relative "production"

# Override settings to be used in staging environments
Rails.application.configure do
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
end

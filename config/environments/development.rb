# frozen_string_literal: true

require "census/api_tests" if ENV["API_TESTS"]

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don"t have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Force SSL access
  config.force_ssl = false

  Settings.security.allowed_ips.development&.each { |ip| BetterErrors::Middleware.allow_ip! ip }

  I18n::Debug.logger = Logger.new(Rails.root.join("log", "i18n-debug.log"))

  # Log file max size
  config.logger = ActiveSupport::Logger.new(config.paths["log"].first, 1, 100 * 1024 * 1024)

  # Don't shut Ahoy requests in console
  Ahoy.quiet = false

  # Deliver emails to letter opener
  config.action_mailer.delivery_method = :letter_opener
end

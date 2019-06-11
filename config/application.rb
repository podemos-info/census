# frozen_string_literal: true

require_relative "boot"

require "dotenv/load"

require "rails"
# Pick the frameworks you want:
require "action_cable/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Census
  class Application < Rails::Application
    config.load_defaults 5.1

    config.middleware.use Rack::Attack

    config.exceptions_app = routes

    # Prevent host header injection (http://carlos.bueno.org/2008/06/host-header-injection.html)
    if Settings.security.host_url
      routes.default_url_options = { host: Settings.security.host_url }
      config.action_controller.asset_host = Settings.security.host_url
    end

    if Settings.security.cas_server.present?
      require "rack-cas"
      require "rack-cas/session_store/active_record"
      config.rack_cas.server_url = Settings.security.cas_server
      config.rack_cas.session_store = RackCAS::ActiveRecordStore
    end

    preload_paths = %w(app/decorators/concerns app/forms/**/ app/jobs/concerns app/models/**/ app/services/**/).freeze
    config.eager_load_paths += Dir[*preload_paths]
  end
end

# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.ignore_host "127.0.0.1"

  config.cassette_library_dir = File.expand_path("../factories/vcr_cassettes", __dir__)

  config.default_cassette_options = { record: ENV["VCR_RECORD_MODE"]&.to_sym || :new_episodes }

  config.allow_http_connections_when_no_cassette = true

  config.hook_into :webmock
end

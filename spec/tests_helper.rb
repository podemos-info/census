# frozen_string_literal: true

require "capybara/rspec"

require "shared/devise_login"
require "shared/only_authorized_api_clients"
require "shared/only_authorized_payment_callbacks"

require "simplecov"
SimpleCov.start "rails"

if ENV["CI"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "vcr"
VCR.configure do |config|
  config.cassette_library_dir = "spec/factories/vcr_cassettes"
  config.hook_into :webmock
end

# Only useful for request tests
def override_ip(the_ip)
  allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return(the_ip)
end

def override_current_admin(admin)
  allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)
end

# hash with file data that will be received by the API
def api_attachment_format(attachment)
  {
    filename: File.basename(attachment.file.path),
    content_type: attachment.content_type,
    base64_content: Base64.encode64(attachment.file.file.read)
  }
end

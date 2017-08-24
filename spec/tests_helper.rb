# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "codecov"
SimpleCov.formatter = SimpleCov::Formatter::Codecov

# Only useful for request tests
def use_ip(ip)
  allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return(ip)
end

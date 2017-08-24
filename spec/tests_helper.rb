# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "codecov"
SimpleCov.formatter = SimpleCov::Formatter::Codecov

# Only useful for request tests
def use_ip ip
  Rack::Attack::Request.any_instance.stub(:ip).and_return(ip)
end
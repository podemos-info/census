# frozen_string_literal: true

require "capybara/rails"
require "capybara/rspec"

RSpec.configure do |config|
  config.before(:each, type: :system) do |sample|
    driven_by :rack_test
  end
end

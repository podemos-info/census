# frozen_string_literal: true

require "capybara/rails"
require "capybara/rspec"
require "capybara/apparition"

Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, type: :system) do |sample|
    if sample.metadata[:js]
      driven_by :apparition
    else
      driven_by :rack_test
    end
  end
end

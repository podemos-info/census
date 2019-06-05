# frozen_string_literal: true

TEST_USER_AGENT = "Google Chrome Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

module AhoyControllerHelper
  def self.included(base)
    base.before do
      request.env["HTTP_USER_AGENT"] = TEST_USER_AGENT if request.respond_to?(:env)
    end
  end
end

module AhoySystemHelper
  def self.included(base)
    base.before do
      page.driver.header("User-Agent", TEST_USER_AGENT)
    end
  end
end

RSpec.configure do |config|
  config.include AhoyControllerHelper, type: :controller
  config.include AhoySystemHelper, type: :system
end

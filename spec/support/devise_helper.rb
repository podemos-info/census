# frozen_string_literal: true

module DeviseHelper
  def override_current_admin(admin)
    allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.include DeviseHelper, type: :controller
end

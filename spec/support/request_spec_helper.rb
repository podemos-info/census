# frozen_string_literal: true

module RequestSpecHelper
  def self.included(base)
    base.before { Warden.test_mode! }
    base.after { Warden.test_reset! }
  end

  def sign_in(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def override_ip(the_ip)
    allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return(the_ip)
  end

  private

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end

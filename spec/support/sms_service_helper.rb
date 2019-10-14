# frozen_string_literal: true

module SmsServiceHelper
  def stub_sms_service(username)
    Esendex.username = username
    instance_double = object_double(Esendex::Account.new, send_message: true)
    sms_service = class_double("Esendex::Account").as_stubbed_const
    allow(sms_service).to receive(:new).and_return(instance_double)
    instance_double
  end
end

RSpec.configure do |config|
  config.include SmsServiceHelper
end

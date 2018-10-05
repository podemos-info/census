# frozen_string_literal: true

def stub_sms_service(username)
  Esendex.username = username
  instance_double = object_double(Esendex::Account.new, send_message: true)
  sms_service = class_double("Esendex::Account").as_stubbed_const
  allow(sms_service).to receive(:new).and_return(instance_double)
  instance_double
end

# frozen_string_literal: true

shared_context "when sending SMSs" do
  before { sms_service }

  let(:sms_service_username) { "test" }
  let(:sms_service) { stub_sms_service(sms_service_username) }
end

shared_examples_for "an SMS is sent" do
  let(:sms_service_params) { { to: to, body: body } }

  include_context "when sending SMSs"

  it "send the SMS" do
    subject
    expect(sms_service).to have_received(:send_message).with(sms_service_params)
  end
end

shared_examples_for "an SMS is not sent" do
  include_context "when sending SMSs"

  it "send the SMS" do
    subject
    expect(sms_service).not_to have_received(:send_message)
  end
end

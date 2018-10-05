# frozen_string_literal: true

require "rails_helper"

describe People::StartPhoneVerification do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::PhoneVerificationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      phone: phone,
      otp_code: otp_code
    )
  end

  let(:phone) { "0034000000000" }
  let(:otp_code) { "1234567" }

  include_context "when sending SMSs"

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it_behaves_like "an SMS is sent" do
      let(:to) { phone }
      let(:body) { "Tu código de activación es 1234567" }
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it_behaves_like "an SMS is not sent"
  end
end

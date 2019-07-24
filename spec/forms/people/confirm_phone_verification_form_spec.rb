# frozen_string_literal: true

require "rails_helper"
require "census/api_tests"
ROTP::TOTP.predictable = false

describe People::ConfirmPhoneVerificationForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      phone: phone,
      received_code: received_code
    )
  end

  let(:person) { create(:person) }
  let(:person_id) { person.id }
  let(:phone) { nil }
  let(:phone_for_received_code) { phone }
  let(:received_code) { described_class.new(person_id: person_id, phone: phone_for_received_code).otp_code }

  it { is_expected.to be_valid }

  context "with an invalid received_code" do
    let(:received_code) { "9876543" }

    it { is_expected.to be_invalid }
  end

  context "with an expired received_code" do
    around do |example|
      received_code
      Timecop.freeze(1.month.from_now) { example.run }
    end

    it { is_expected.to be_invalid }
  end

  context "with a different phone number" do
    let(:phone) { build(:person).phone }

    it { is_expected.to be_valid }

    context "with a received_code for another phone number" do
      let(:phone_for_received_code) { person.phone }

      it { is_expected.to be_invalid }
    end
  end

  context "when not testing APIs" do
    let(:received_code) { "9999999" }

    it { is_expected.to be_invalid }
  end

  context "when testing APIs" do
    before { ROTP::TOTP.predictable = true }

    after { ROTP::TOTP.predictable = false }

    it { is_expected.to be_valid }

    context "with the always valid code" do
      let(:received_code) { "9999999" }

      it { is_expected.to be_valid }
    end

    context "with the always invalid code" do
      let(:received_code) { "0000000" }

      it { is_expected.to be_invalid }
    end

    context "with an invalid received_code" do
      let(:received_code) { "9876543" }

      it { is_expected.to be_invalid }
    end
  end
end

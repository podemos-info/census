# frozen_string_literal: true

require "rails_helper"

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
  let(:received_code) { described_class.new(person_id: person_id, phone: phone).otp_code }

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
      let(:received_code) { described_class.new(person_id: person_id, phone: person.phone).otp_code }

      it { is_expected.to be_invalid }
    end
  end
end

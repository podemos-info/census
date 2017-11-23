# frozen_string_literal: true

require "rails_helper"

describe Orders::CreditCardAuthorizedOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      campaign_code: campaign_code,
      authorization_token: authorization_token,
      expiration_year: expiration_year,
      expiration_month: expiration_month
    )
  end
  let(:order) { build(:order, :external_verified) }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:campaign_code) { order.campaign.campaign_code }
  let(:authorization_token) { order.payment_method.authorization_token }
  let(:expiration_year) { order.payment_method.expiration_year }
  let(:expiration_month) { order.payment_method.expiration_month }

  it { expect(subject).to be_valid }

  context "without authorization token" do
    let(:authorization_token) { nil }
    it { is_expected.to be_invalid }
  end

  context "without expiration year" do
    let(:expiration_year) { nil }
    it { is_expected.to be_invalid }
  end

  context "without expiration month" do
    let(:expiration_month) { nil }
    it { is_expected.to be_invalid }
  end

  describe "#payment_method" do
    subject(:method) { form.payment_method }

    it { is_expected.to be_present }

    it "matches the given payment method authorization token" do
      expect(subject.authorization_token).to eq(authorization_token)
    end

    it "matches the given payment method expiration year" do
      expect(subject.expiration_year).to eq(expiration_year)
    end

    it "matches the given payment method expiration month" do
      expect(subject.expiration_month).to eq(expiration_month)
    end
  end
end

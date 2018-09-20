# frozen_string_literal: true

require "rails_helper"

describe Orders::DirectDebitOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      campaign_code: campaign_code,
      iban: iban
    )
  end

  let(:order) { build(:order) }
  let(:iban) { order.payment_method.iban }
  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:campaign_code) { order.campaign.campaign_code }

  it { is_expected.to be_valid }

  context "with an invalid IBAN" do
    let(:iban) { "ES0000030000300000000000" }

    it { is_expected.to be_invalid }
  end

  context "with a non-SEPA IBAN" do
    let(:iban) { "AD7100030000300000000000" }

    it { is_expected.to be_invalid }
  end

  describe "#payment_method" do
    subject(:method) { form.payment_method }

    it { is_expected.to be_present }

    it "matches the given payment method IBAN" do
      expect(subject.iban).to eq(iban)
    end
  end
end

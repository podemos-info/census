# frozen_string_literal: true

require "rails_helper"

describe Orders::DirectDebitOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      iban: iban
    )
  end
  let(:order) { build(:order) }
  let(:iban) { "ES8700030000300000000000" }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:currency) { order.currency }

  it { expect(subject).to be_valid }

  context "with an invalid IBAN" do
    let(:iban) { "ES0000030000300000000000" }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  context "with a non-SEPA IBAN" do
    let(:iban) { "AD7100030000300000000000" }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe PaymentMethods::DirectDebit, :db do
  subject(:direct_debit) { build(:direct_debit) }

  it { is_expected.to be_valid }

  describe "#reprocessable?" do
    it { is_expected.to be_reprocessable }
  end

  describe "sensible_data" do
    subject(:stored_data) { described_class.last }

    before { direct_debit }

    let(:direct_debit) { create(:direct_debit, iban: iban) }
    let(:iban) { "AD7100030000300000000000" }

    it { is_expected.to be_valid }

    it "doesn't store iban on the non-encrypted field" do
      expect(subject.information.to_json).not_to include(iban)
    end

    it "stores iban on the encrypted field" do
      expect(subject.sensible_data).to have_key("iban")
    end

    it "returns the right value when loaded from the database" do
      expect(subject.iban).to eq(iban)
    end
  end
end

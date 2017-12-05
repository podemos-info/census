# frozen_string_literal: true

require "rails_helper"

describe PaymentMethod, :db do
  subject(:payment_method) { build(:direct_debit) }

  it { is_expected.to be_valid }

  describe "#status" do
    subject(:status) { payment_method.status }

    it { is_expected.to eq("pending") }

    context "when verified" do
      let(:payment_method) { build(:direct_debit, verified: true) }
      it { is_expected.to eq("active") }
    end

    context "when inactive" do
      let(:payment_method) { build(:direct_debit, inactive: true) }
      it { is_expected.to eq("inactive") }
    end

    context "when inactive and verified" do
      let(:payment_method) { build(:direct_debit, verified: true, inactive: true) }
      it { is_expected.to eq("inactive") }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Orders::ExistingPaymentMethodOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      campaign_code: campaign_code,
      payment_method_id: payment_method_id
    )
  end
  let(:order) { build(:order) }
  let(:payment_method_id) { create(:credit_card, person: order.person).id }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:campaign_code) { order.campaign_code }

  it { is_expected.to be_valid }

  context "without a payment_method_id" do
    let(:payment_method_id) { nil }
    it { is_expected.to be_invalid }
  end

  describe "#payment_method" do
    subject(:method) { form.payment_method }

    it { is_expected.to be_present }

    it "matches the given payment method id" do
      expect(subject.id).to eq(payment_method_id)
    end
  end
end

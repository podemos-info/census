# frozen_string_literal: true

require "rails_helper"

describe Orders::ExistingPaymentMethodOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      payment_method_id: payment_method_id
    )
  end
  let(:order) { build(:order) }
  let(:payment_method_id) { create(:credit_card, person: order.person).id }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:currency) { order.currency }

  it { expect(subject).to be_valid }

  context "without a payment_method_id" do
    let(:payment_method_id) { nil }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end
end

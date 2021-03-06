# frozen_string_literal: true

require "rails_helper"

describe Orders::CreditCardExternalOrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      campaign_code: campaign_code,
      return_url: return_url
    )
  end

  let(:order) { build(:order, :external) }
  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:campaign_code) { order.campaign.campaign_code }
  let(:return_url) { order.payment_method.return_url }

  it { expect(subject).to be_valid }

  context "without a return url" do
    let(:return_url) { nil }

    it { is_expected.to be_invalid }
  end

  describe "#payment_method" do
    subject(:method) { form.payment_method }

    it { is_expected.to be_present }

    it "matches the given payment method return url" do
      expect(subject.return_url).to eq(return_url)
    end
  end
end

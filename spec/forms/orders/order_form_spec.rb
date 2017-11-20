# frozen_string_literal: true

require "rails_helper"

describe Orders::OrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount,
      campaign_code: campaign_code
    )
  end
  let(:order) { build(:order) }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:campaign_code) { order.campaign_code }

  it { is_expected.to be_valid }

  context "without person" do
    let(:person_id) { nil }
    it { is_expected.to be_invalid }
  end

  context "without description" do
    let(:description) { nil }
    it { is_expected.to be_invalid }
  end

  context "with negative amount" do
    let(:amount) { -1 }
    it { is_expected.to be_invalid }
  end

  context "without amount" do
    let(:amount) { nil }
    it { is_expected.to be_invalid }
  end

  context "without campaign code" do
    let(:campaign_code) { nil }
    it { is_expected.to be_invalid }
  end
end

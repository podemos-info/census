# frozen_string_literal: true

require "rails_helper"

describe Orders::OrderForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
      description: description,
      amount: amount
    )
  end
  let(:order) { build(:order) }

  let(:person_id) { order.person.id }
  let(:description) { order.description }
  let(:amount) { order.amount }
  let(:currency) { order.currency }

  it { expect(subject).to be_valid }

  context "without person" do
    let(:person_id) { nil }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  context "without description" do
    let(:description) { nil }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  context "with negative amount" do
    let(:amount) { -1 }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  context "without amount" do
    let(:amount) { nil }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end
end

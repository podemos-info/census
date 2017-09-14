# frozen_string_literal: true

require "rails_helper"

describe Orders::OrdersBatchForm do
  subject(:form) do
    described_class.new(
      description: description,
      orders: orders
    )
  end
  let(:orders_batch) { build(:orders_batch) }
  let(:orders) { orders_batch.orders }
  let(:description) { orders_batch.description }

  it { expect(subject).to be_valid }

  context "without orders" do
    let(:orders) { [] }

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
end

# frozen_string_literal: true

require "rails_helper"

describe Orders::OrdersBatchForm do
  subject(:form) do
    described_class.new(
      description: description,
      orders_from: orders_from,
      orders_to: orders_to
    )
  end
  let(:orders_batch) { build(:orders_batch) }
  let(:orders_from) { 1.year.ago }
  let(:orders_to) { Time.now }
  let(:description) { orders_batch.description }
  let(:orders) do
    orders_batch.orders.map do |order|
      order.orders_batch = nil
      order.save
      order
    end
  end

  it { is_expected.to be_valid }

  context "without orders_from" do
    let(:orders_from) { nil }

    it "is invalid" do
      is_expected.to be_invalid
    end
  end

  context "without orders_to" do
    let(:orders_to) { nil }

    it "is invalid" do
      is_expected.to be_invalid
    end
  end

  context "without description" do
    let(:description) { nil }

    it "is invalid" do
      is_expected.to be_invalid
    end
  end

  describe "#orders" do
    subject(:method) { form.orders }

    it { is_expected.to eq(orders) }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Payments::CreateOrdersBatch do
  subject(:create_orders_batch) { described_class.call(description, orders) }

  let(:orders_batch) { build(:orders_batch) }
  let(:orders) { orders_batch.orders }
  let(:description) { orders_batch.description }

  describe "when valid" do
    it "broadcasts :ok" do
      is_expected.to broadcast(:ok)
    end

    it "saves the order" do
      expect { subject } .to change { OrdersBatch.count } .by(1)
    end
  end

  describe "when has no orders" do
    let(:orders) { [] }

    it "broadcasts :invalid" do
      is_expected.to broadcast(:invalid)
    end

    it "doesn't save the orders batch" do
      expect { subject } .not_to change { OrdersBatch.count }
    end
  end
end

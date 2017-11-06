# frozen_string_literal: true

require "rails_helper"

describe Payments::CreateOrdersBatch do
  subject(:create_orders_batch) { described_class.call(form: form, admin: admin) }

  let(:admin) { create(:admin) }
  let(:orders_batch) { build(:orders_batch) }
  let(:valid) { true }
  let(:form) do
    instance_double(
      OrdersBatchForm,
      invalid?: !valid,
      valid?: valid,
      description: orders_batch.description,
      orders: orders_batch.orders
    )
  end

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "saves the order" do
      expect { subject } .to change { OrdersBatch.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't save the orders batch" do
      expect { subject } .not_to change { OrdersBatch.count }
    end
  end
end

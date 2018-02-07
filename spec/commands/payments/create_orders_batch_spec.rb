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

    it "doesn't modify the orders for the orders batch" do
      expect { subject } .not_to change { Order.where(id: orders_batch.orders).pluck(:updated_at) }
    end
  end

  describe "when orders batch save fails" do
    before { allow_any_instance_of(OrdersBatch).to receive(:save!).and_raise(ActiveRecord::Rollback) }

    it "broadcasts :error" do
      expect { subject } .to broadcast(:error)
    end

    it "doesn't save the orders batch" do
      expect { subject } .not_to change { OrdersBatch.count }
    end
  end

  describe "when order save fails" do
    before { allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::Rollback) }

    it "broadcasts :error" do
      expect { subject } .to broadcast(:error)
    end

    it "doesn't save the orders batch" do
      expect { subject } .not_to change { OrdersBatch.count }
    end

    it "doesn't modify the orders for the orders batch" do
      expect { subject } .not_to change { Order.where(id: orders_batch.orders).pluck(:updated_at) }
    end
  end
end

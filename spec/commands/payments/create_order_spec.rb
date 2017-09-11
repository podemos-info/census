# frozen_string_literal: true

require "rails_helper"

describe Payments::CreateOrder do
  subject(:create_order) { described_class.call(form) }

  let(:order) { build(:order) }
  let(:valid) { true }
  let(:form) do
    instance_double(
      OrderForm,
      invalid?: !valid,
      valid?: valid,
      description: order.description,
      person: order.person,
      amount: order.amount,
      payment_method: order.payment_method,
      currency: order.currency
    )
  end

  describe "when valid" do
    it "broadcasts :ok" do
      is_expected.to broadcast(:ok)
    end

    it "saves the order" do
      expect { subject } .to change { Order.count } .by(1)
    end
  end

  describe "when require an external authentication" do
    let(:order) { build(:order, :external) }
    it "broadcasts :external" do
      expect { subject } .to broadcast(:external)
    end

    it "returns the external parameters" do
      subject do
        on(:external) do |external_parameters|
          expect(external_parameters).to include(:action, :fields)
        end
      end
    end

    it "doesn't save the order" do
      expect { subject } .not_to change { Order.count }
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't save the order" do
      expect { subject } .not_to change { Order.count }
    end
  end
end

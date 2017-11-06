# frozen_string_literal: true

require "rails_helper"

describe Payments::ProcessOrder do
  subject(:process_order) do
    VCR.use_cassette(cassete) do
      described_class.call(order: order, admin: admin)
    end
  end

  let(:order) { create(:order, :credit_card, :external_verified) }
  let(:admin) { create(:admin) }

  describe "when valid" do
    let(:cassete) { "valid_process_order_command" }
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates the order state to processed" do
      expect { subject } .to change { Order.find(order.id).state } .to("processed")
    end
  end

  describe "when the payment fails" do
    let(:cassete) { "failed_process_order_command" }
    let(:order) { create(:order, :credit_card) }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates the order state to error" do
      expect { subject } .to change { Order.find(order.id).state } .to("error")
    end
  end

  describe "when invalid" do
    let(:cassete) { "invalid_process_order_command" }
    let(:order) { nil }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end
  end
end

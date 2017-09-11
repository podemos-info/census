# frozen_string_literal: true

require "rails_helper"

describe Payments::ProcessOrder do
  subject(:process_order) { described_class.call(order, processed_by) }
  let(:order) { create(:order, :credit_card) }
  let!(:processed_by) { create(:person) }

=begin
  describe "when valid" do
    it "broadcasts :ok" do
      is_expected.to broadcast(:ok)
    end

    it "saves the order" do
      expect { subject } .to change { Order.count } .by(1)
    end

    it "saves the payment method" do
      expect { subject } .to change { PaymentMethod.count } .by(1)
    end

    it "sets processing information" do
      expect { subject } .to change { Order.find(order.id).processed_by } .to processed_by
      expect { subject } .to change { Order.find(order.id).processed_at }
    end
  end
=end

  describe "when invalid" do
    let(:order) { create(:order) }

    it "broadcasts :invalid" do
      is_expected.to broadcast(:invalid)
    end

    it "doesn't update the order" do
      expect { subject } .not_to change { Order.find(order.id).state }
    end
  end
end

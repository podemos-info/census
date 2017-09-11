# frozen_string_literal: true

require "rails_helper"

describe Payments::ProcessOrder do
  subject(:process_order) { described_class.call(order, processed_by) }
  let(:order) { create(:order, :credit_card) }
  let!(:processed_by) { create(:person) }

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

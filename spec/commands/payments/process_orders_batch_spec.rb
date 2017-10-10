# frozen_string_literal: true

require "rails_helper"

describe Payments::ProcessOrdersBatch do
  subject(:process_orders_batch) do
    VCR.use_cassette(cassete) do
      described_class.call(orders_batch, processed_by)
    end
  end
  let(:orders_batch) { create(:orders_batch) }
  let!(:processed_by) { create(:admin) }
  let(:force_valid_bic) { true }

  before do
    allow(IbanBic).to receive(:calculate_bic).and_return("ABCESXXX") if force_valid_bic
  end

  describe "when valid" do
    let(:cassete) { "valid_process_orders_batch_command" }
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates the orders orders batch" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  describe "when invalid" do
    let(:cassete) { "invalid_process_orders_batch_command" }
    let(:processed_by) { nil }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  describe "when needs review" do
    let(:force_valid_bic) { false }
    let(:cassete) { "needs_review_process_orders_batch_command" }
    let(:processed_by) { nil }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Payments::ProcessOrdersBatch do
  subject(:process_orders_batch) do
    VCR.use_cassette(cassete) do
      described_class.call(orders_batch: orders_batch, admin: admin)
    end
  end
  let!(:admin) { create(:admin) }
  let(:orders_batch) { create(:orders_batch) }

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
    let(:admin) { nil }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  describe "when needs review" do
    let(:orders_batch) { create(:orders_batch, :with_issues) }
    let(:cassete) { "needs_review_process_orders_batch_command" }

    it "broadcasts :review" do
      expect { subject } .to broadcast(:review)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end
end

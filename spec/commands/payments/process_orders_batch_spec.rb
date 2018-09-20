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

  context "when valid" do
    let(:cassete) { "valid_process_orders_batch_command" }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates the orders orders batch" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  context "when invalid" do
    let(:cassete) { "invalid_process_orders_batch_command" }
    let(:admin) { nil }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  context "when needs review" do
    let(:orders_batch) { create(:orders_batch, :with_issues) }
    let(:cassete) { "needs_review_process_orders_batch_command" }

    it "broadcasts :review" do
      expect { subject } .to broadcast(:review)
    end

    it "doesn't update the orders batch" do
      expect { subject } .not_to change { OrdersBatch.find(orders_batch.id).updated_at }
    end
  end

  context "when there are too many errors saving the payment methods" do
    let(:cassete) { "process_orders_batch_command_too_many_save_payment_method_errors" }

    before { stub_command("Payments::SavePaymentMethod", :error) }

    it "broadcasts :processor_aborted and error" do
      expect { subject } .to broadcast(:processor_aborted).and broadcast(:error)
    end
  end

  context "when there are too many errors saving the orders" do
    before { allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::Rollback) }

    let(:cassete) { "process_orders_batch_command_too_many_save_order_errors" }

    it "broadcasts :processor_aborted and error" do
      expect { subject } .to broadcast(:processor_aborted).and broadcast(:error)
    end

    it "logs order information to avoid losing information" do
      expect(Census::Payments.logger).to receive(:error).exactly(2 * Settings.payments.orders_batch_processing_errors_limit).times
      subject
    end
  end
end

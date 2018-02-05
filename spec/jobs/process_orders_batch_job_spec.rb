# frozen_string_literal: true

require "rails_helper"

describe ProcessOrdersBatchJob, type: :job do
  subject(:job) do
    VCR.use_cassette(cassete) do
      described_class.perform_now(orders_batch: orders_batch, admin: current_admin)
    end
  end
  let(:orders_batch) { create(:orders_batch) }
  let(:current_admin) { create(:admin, :finances) }

  context "when orders are ok" do
    let(:cassete) { "orders_batch_job_payment" }

    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
    it "sets the orders batch processed date" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at } .from(nil)
    end
    it "sets the orders batch processed user" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(nil)
    end
    it "sets the orders as processed or error" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:state).uniq } .from(["pending"])
    end
    it "saves the server responses" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:raw_response).uniq } .from([nil])
    end
    it "creates a new download for the orders batch" do
      expect { subject } .to change { Download.count } .by(1)
    end
  end

  context "when reprocessing orders" do
    let(:orders_batch) { create(:orders_batch, :processed) }
    let(:cassete) { "orders_batch_job_payment_reprocess" }

    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
    it "sets the orders batch processed date" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at } .from(orders_batch.processed_at)
    end
    it "sets the orders batch processed user" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(orders_batch.processed_by)
    end
    it "creates a new download for the orders batch" do
      expect { subject } .to change { Download.count } .by(1)
    end
  end

  context "when orders have issues" do
    let(:orders_batch) { create(:orders_batch, :with_issues) }
    let(:cassete) { "orders_batch_job_payment_review" }

    it "doesn't complete the job" do
      expect(subject.result).to eq(:review)
    end
  end

  context "when orders invalid parameters" do
    let(:cassete) { "orders_batch_job_invalid" }
    let(:orders_batch) { nil }

    it "doesn't complete the job" do
      expect(subject.result).to eq(:invalid)
    end
  end

  context "when too many error orders for a processor" do
    let(:cassete) { "orders_batch_job_too_many_errors" }
    before { stub_command("Payments::SavePaymentMethod", :error) }

    it "doesn't complete the job" do
      expect(subject.result).to eq(:error)
    end
  end

  context "when errors on generating downloadable file" do
    let(:cassete) { "orders_batch_job_errors_on_charge" }
    before { stub_command("Downloads::CreateDownload", :invalid) }

    it "doesn't complete the job" do
      expect(subject.result).to eq(:error)
    end
  end
end

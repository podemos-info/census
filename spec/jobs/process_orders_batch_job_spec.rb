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
  let(:job_record) { ActiveJobReporter::Job.first }

  context "when orders are ok" do
    let(:cassete) { "orders_batch_job_payment" }

    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end

    it "sets the orders batch processed date" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at } .from(nil)
    end

    it "sets the orders batch processed user" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(nil)
    end

    it "sets the orders as processed or error" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:state).uniq } .from(%w(pending))
    end

    it "saves the server responses" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:raw_response).uniq } .from([nil])
    end

    it "creates a new download for the orders batch" do
      expect { subject } .to change(Download, :count).by(1)
    end
  end

  context "when reprocessing orders" do
    let(:orders_batch) { create(:orders_batch, :processed) }
    let(:cassete) { "orders_batch_job_payment_reprocess" }

    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end

    it "sets the orders batch processed date" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at.to_s } .from(orders_batch.processed_at.to_s)
    end

    it "sets the orders batch processed user" do
      expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(orders_batch.processed_by)
    end

    it "creates a new download for the orders batch" do
      expect { subject } .to change(Download, :count).by(1)
    end
  end

  context "when orders have issues" do
    let(:orders_batch) { create(:orders_batch, :with_issues) }
    let(:cassete) { "orders_batch_job_payment_review" }

    it "doesn't complete the job" do
      subject
      expect(job_record.result).to eq("review")
    end
  end

  context "when has invalid parameters" do
    let(:orders_batch) { nil }
    let(:cassete) { "orders_batch_job_invalid" }

    it "doesn't complete the job" do
      subject
      expect(job_record.result).to eq("invalid")
    end
  end

  context "when too many error orders for a processor" do
    before { stub_command("Payments::SavePaymentMethod", :error) }

    let(:cassete) { "orders_batch_job_too_many_errors" }

    it "doesn't complete the job" do
      subject
      expect(job_record.result).to eq("error")
    end
  end

  context "when check issues fails" do
    before { stub_command("Issues::CheckIssues", :error) }

    let(:cassete) { "orders_batch_job_check_issues_fails" }

    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end
  end

  context "when errors on generating downloadable file" do
    before { stub_command("Downloads::CreateDownload", :invalid) }

    let(:cassete) { "orders_batch_job_errors_on_charge" }

    it "doesn't complete the job" do
      subject
      expect(job_record.result).to eq("error")
    end
  end
end

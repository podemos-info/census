# frozen_string_literal: true

require "rails_helper"

describe CheckPaymentIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(issuable: payment_method, admin: current_admin) }

  let(:payment_method) { create(:direct_debit) }
  let(:current_admin) { create(:admin, :finances) }

  context "when everything works ok" do
    let(:job_record) { ActiveJobReporter::Job.last }
    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end
  end
end

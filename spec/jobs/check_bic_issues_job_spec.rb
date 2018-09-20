# frozen_string_literal: true

require "rails_helper"

describe CheckBicIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(country: country, bank_code: bank_code, admin: current_admin) }

  let(:country) { direct_debit.iban_parts[:country] }
  let(:bank_code) { direct_debit.iban_parts[:bank_code] }
  let(:direct_debit) { create(:direct_debit) }
  let(:current_admin) { create(:admin, :finances) }

  context "when everything works ok" do
    let(:job_record) { ActiveJobReporter::Job.last }

    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end
  end
end

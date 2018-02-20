# frozen_string_literal: true

require "rails_helper"

describe UpdateProcedureJob, type: :job do
  subject(:job) { described_class.perform_now(procedure: procedure, admin: current_admin) }

  let(:procedure) { create(:registration) }
  let(:current_admin) { create(:admin, :lopd) }

  context "when everything works ok" do
    let(:job_record) { ActiveJobReporter::Job.last }
    it "completes the job" do
      subject
      expect(job_record.result).to eq("ok")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe CheckBicIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(country: country, bank_code: bank_code, admin: current_admin) }

  let(:country) { "ES" }
  let(:bank_code) { "1234" }
  let(:current_admin) { create(:admin, :finances) }

  context "when everything works ok" do
    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe CheckPersonIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(person: person, admin: current_admin) }

  let(:person) { create(:person) }
  let(:current_admin) { create(:admin, :lopd) }

  context "when everything works ok" do
    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
  end
end

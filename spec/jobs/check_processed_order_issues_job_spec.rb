# frozen_string_literal: true

require "rails_helper"

describe CheckProcessedOrderIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(order: order, admin: current_admin) }

  let(:order) { create(:order, :processed) }
  let(:current_admin) { create(:admin, :finances) }

  context "when everything works ok" do
    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
  end
end

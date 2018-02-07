# frozen_string_literal: true

require "rails_helper"

describe CheckPaymentMethodIssuesJob, type: :job do
  subject(:job) { described_class.perform_now(payment_method: payment_method, admin: current_admin) }

  let(:payment_method) { create(:direct_debit) }
  let(:current_admin) { create(:admin, :finances) }

  context "when everything works ok" do
    it "completes the job" do
      expect(subject.result).to eq(:ok)
    end
  end
end

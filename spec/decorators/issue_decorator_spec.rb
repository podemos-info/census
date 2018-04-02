# frozen_string_literal: true

require "rails_helper"

describe IssueDecorator do
  subject(:decorator) { issue.decorate(context: { current_admin: admin }) }
  let(:admin) { build(:admin) }

  describe "#description" do
    subject(:method) { decorator.description }
    context "when has a text description" do
      let(:issue) { build(:issue, description: "a description") }

      it { is_expected.to eq("a description") }
    end

    context "when has a description for a response code" do
      let(:issue) { build(:processing_issue, description: "wrong_data", issuable: order) }
      let(:order) { build(:order, :external, :processed) }

      it { is_expected.to eq("Datos del método de pago incorrectos") }
    end
  end
end

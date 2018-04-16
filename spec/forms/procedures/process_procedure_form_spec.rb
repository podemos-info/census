# frozen_string_literal: true

require "rails_helper"

describe Procedures::ProcessProcedureForm do
  subject(:form) do
    described_class.new(
      procedure: procedure,
      processed_by: admin,
      action: action,
      comment: comment
    )
  end

  let!(:procedure) { create(:registration) }
  let(:action) { :accept }
  let(:comment) { "This is a comment" }
  let!(:admin) { create(:admin) }

  it "is accepting" do
    is_expected.to be_accepting
  end

  it "is valid" do
    is_expected.to be_valid
  end

  context "when event is undo" do
    let(:action) { :undo }
    it "is not accepting" do
      is_expected.not_to be_accepting
    end

    it "is invalid" do
      is_expected.to be_invalid
    end
  end

  context "when has no comment and is not accepting" do
    let(:action) { :reject }
    let(:comment) { "" }

    it "is not accepting" do
      is_expected.not_to be_accepting
    end

    it "is invalid" do
      is_expected.to be_invalid
    end
  end

  context "when the admin is the person affected by the procedure" do
    let(:admin) { create(:admin, person: procedure.person) }

    it "is invalid" do
      is_expected.to be_invalid
    end
  end
end

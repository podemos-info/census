# frozen_string_literal: true

require "rails_helper"

describe Procedures::VerificationDocument, :db do
  let!(:person) { create(:person) }
  let(:procedure) { create(:verification_document, person: person) }

  subject { procedure }

  it { is_expected.to be_valid }

  it "#check_acceptable always returns true" do
    expect(procedure.check_acceptable).to be_truthy
  end

  it "acceptance changes person verification status" do
    expect { procedure.accept } .to change { Person.find(person.id).verified? } .from(false).to(true)
  end

  context "after accepting the procedure" do
    before do
      procedure.accept
    end

    it "undo revert person level to previous value" do
      expect { procedure.undo } .to change { Person.find(person.id).verified? } .from(true).to(false)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Procedures::VerificationDocument, :db do
  let!(:person) { create(:person) }
  let(:procedure) { create(:verification_document, :ready_to_process, person: person) }

  subject { procedure }

  it { is_expected.to be_valid }

  it "#acceptable? returns true" do
    expect(procedure.acceptable?).to be_truthy
  end

  it "acceptance changes person verification status" do
    expect { procedure.accept! } .to change { Person.find(person.id).verified? } .from(false).to(true)
  end

  it "rejection does not change person verification status" do
    expect { procedure.reject! } .to_not change { Person.find(person.id).verified? }
  end

  context "after accepting the procedure" do
    before do
      procedure.accept!
    end

    it "undo revert person level to previous value" do
      expect { procedure.undo! } .to change { Person.find(person.id).verified? } .from(true).to(false)
    end
  end

  context "after rejecting the procedure" do
    before do
      procedure.reject!
    end

    it "undo does not change person level" do
      expect { procedure.undo! } .to_not change { Person.find(person.id).verified? }
    end
  end
end

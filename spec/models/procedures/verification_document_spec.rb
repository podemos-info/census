# frozen_string_literal: true

require "rails_helper"

describe Procedures::DocumentVerification, :db do
  subject(:procedure) { create(:document_verification, :ready_to_process, person: person) }
  let!(:person) { create(:person) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is not auto_processable" do
    is_expected.not_to be_auto_processable
  end

  it "acceptance changes person verification status" do
    expect { procedure.accept! } .to change { Person.find(person.id).verified? } .from(false).to(true)
  end

  it "rejection does not change person verification status" do
    expect { procedure.reject! } .to_not change { Person.find(person.id).verified? }
  end

  with_versioning do
    context "after accepting the procedure" do
      before do
        procedure.accept!
      end

      it "undo revert person membership level to previous value" do
        expect { procedure.undo! } .to change { Person.find(person.id).verified? } .from(true).to(false)
      end
    end

    context "after rejecting the procedure" do
      before do
        procedure.reject!
      end

      it "undo does not change person membership level" do
        expect { procedure.undo! } .to_not change { Person.find(person.id).verified? }
      end
    end
  end
end

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

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "changes person verification status" do
      expect { subject } .to change { Person.find(person.id).verified? } .from(false).to(true)
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            person: person.qualified_id,
            state: person.state,
            membership_level: person.membership_level,
            verification: "verified",
            scope: person.scope&.code
          }
        ]
      end
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "does not change person verification status" do
      expect { subject } .to_not change { Person.find(person.id).verified? }
    end

    it_behaves_like "an event not notifiable with hutch"
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

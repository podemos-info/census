# frozen_string_literal: true

require "rails_helper"

describe Procedures::DocumentVerification, :db do
  subject(:procedure) { create(:document_verification, :ready_to_process, person: person) }

  let!(:person) { create(:person) }

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.not_to be_auto_processable }

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
            scope_code: person.scope&.code
          }
        ]
      end
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "does not change person verification status" do
      expect { subject } .not_to change { Person.find(person.id).verified? }
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            person: person.qualified_id,
            state: person.state,
            membership_level: person.membership_level,
            verification: "verification_requested",
            scope_code: person.scope&.code
          }
        ]
      end
    end
  end

  with_versioning do
    context "when has accepted the procedure" do
      before do
        procedure.accept!
      end

      it "undo revert person membership level to previous value" do
        expect { procedure.undo! } .to change { Person.find(person.id).verified? } .from(true).to(false)
      end
    end

    context "when has rejected the procedure" do
      before do
        procedure.reject!
      end

      it "undo does not change person membership level" do
        expect { procedure.undo! } .not_to change { Person.find(person.id).verified? }
      end
    end
  end
end

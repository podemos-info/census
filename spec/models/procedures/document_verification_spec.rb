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
      let(:publish_notification) { "census.people.full_status_changed" }
      let(:publish_notification_args) do
        {
          person: procedure.person.qualified_id,
          external_ids: procedure.person.external_ids,
          state: procedure.person.state,
          verification: "verified",
          membership_level: procedure.person.membership_level,
          scope_code: procedure.person.scope&.code,
          document_type: procedure.person.document_type,
          age: procedure.person.age
        }
      end
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "does not change person verification status" do
      expect { subject } .not_to change { Person.find(person.id).verified? }
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { "census.people.full_status_changed" }
      let(:publish_notification_args) do
        {
          person: person.qualified_id,
          external_ids: person.external_ids,
          state: person.state,
          verification: "verification_requested",
          membership_level: person.membership_level,
          scope_code: person.scope&.code,
          document_type: person.document_type,
          age: person.age
        }
      end
    end
  end

  with_versioning do
    context "when has accepted the procedure" do
      before do
        procedure.accept!
      end

      it "undo revert person verification to previous value" do
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

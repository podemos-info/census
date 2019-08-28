# frozen_string_literal: true

require "rails_helper"

describe Procedures::MembershipLevelChange, :db do
  subject(:procedure) { create(:membership_level_change, :ready_to_process, person: person, to_membership_level: "member") }

  let!(:person) { create(:person, :verified) }

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.to be_auto_processable }

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "changes person membership level" do
      expect { subject } .to change { Person.find(person.id).membership_level } .from("follower").to("member")
    end
    it "sends an email to the person" do
      subject
      expect(ActionMailer::Parameterized::DeliveryJob).to have_been_enqueued.on_queue("mailers")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) do
        [
          "census.people.full_status_changed", {
            age: person.age,
            document_type: person.document_type,
            person: person.qualified_id,
            state: person.state,
            membership_level: "member",
            verification: person.verification,
            scope_code: person.scope&.code
          }
        ]
      end
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "rejection does not changes person membership level" do
      expect { subject } .not_to change { Person.find(person.id).membership_level }
    end

    it "doesn't sends an email to the person" do
      subject
      expect(ActionMailer::Parameterized::DeliveryJob).not_to have_been_enqueued.on_queue("mailers")
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  context "when the target membership level is not allowed" do
    before { person }

    let(:person) { create(:person) }

    it { is_expected.not_to be_acceptable }
  end

  with_versioning do
    context "when has accepted the procedure" do
      subject(:undo) { procedure.undo! }

      before { procedure.accept! }

      it "undo revert person membership evel to previous value" do
        expect { subject } .to change { Person.find(person.id).membership_level } .from("member").to("follower")
      end
    end

    context "when has rejected the procedure" do
      subject(:undo) { procedure.undo! }

      before { procedure.reject! }

      it "undo does not change person membership level" do
        expect { subject } .not_to change { Person.find(person.id).membership_level }
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Procedures::MembershipLevelChange, :db do
  subject(:procedure) { create(:membership_level_change, :ready_to_process, person: person, to_membership_level: "member") }
  let!(:person) { create(:person, :verified) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is auto_processable" do
    is_expected.to be_auto_processable
  end

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "changes person membership level" do
      expect { subject } .to change { Person.find(person.id).membership_level } .from("follower").to("member")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { ["census.people.full_status_changed", { person: person.qualified_id }] }
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "rejection does not changes person membership level" do
      expect { subject } .to_not change { Person.find(person.id).membership_level }
    end

    it_behaves_like "an event not notifiable with hutch"
  end

  context "when the target membership level is not allowed" do
    let!(:person) { create(:person) }

    it "#acceptable? returns false" do
      is_expected.not_to be_acceptable
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      it "undo revert person membership evel to previous value" do
        expect { subject } .to change { Person.find(person.id).membership_level } .from("member").to("follower")
      end
    end

    context "after rejecting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.reject! }

      it "undo does not change person membership level" do
        expect { subject } .to_not change { Person.find(person.id).membership_level }
      end
    end
  end
end

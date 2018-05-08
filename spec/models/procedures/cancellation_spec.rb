# frozen_string_literal: true

require "rails_helper"

describe Procedures::Cancellation, :db do
  subject(:procedure) { create(:cancellation, :ready_to_process) }

  let(:person) { procedure.person }
  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is auto_processable" do
    is_expected.to be_auto_processable
  end

  context "when accepted" do
    subject(:accepting) { procedure.accept! }
    let(:publish_notification) do
      {
        routing_key: "census.people.full_status_changed",
        parameters: { person: person.qualified_id }
      }
    end

    it "changes the person state" do
      expect { subject } .to change { person.state } .from("enabled").to("cancelled")
    end
    it "destroys the person" do
      expect { subject } .to change { person.discarded_at } .from(nil)
    end
    include_context "hutch notifications"
  end

  context "when rejected" do
    it "doesn't change the person state" do
      expect { procedure.reject! } .not_to change { person.state } .from("enabled")
    end
    it "doesn't destroy the person" do
      expect { procedure.reject! } .not_to change { person.discarded_at }
    end
    include_context "hutch notifications"
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      it "recovers the person" do
        expect { subject } .to change { person.discarded_at } .to(nil)
      end
      it "recovers the person state" do
        expect { subject } .to change { person.state } .from("cancelled").to("enabled")
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Procedures::Cancellation, :db do
  subject(:procedure) { create(:cancellation, :ready_to_process) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is auto_processable" do
    is_expected.to be_auto_processable
  end

  context "when accepted" do
    it "changes the person state" do
      expect { procedure.accept! } .to change { procedure.person.state } .from("enabled").to("cancelled")
    end
    it "destroys the person" do
      expect { procedure.accept! } .to change { procedure.person.discarded_at } .from(nil)
    end
  end

  context "when rejected" do
    it "doesn't change the person state" do
      expect { procedure.reject! } .not_to change { procedure.person.state } .from("enabled")
    end
    it "doesn't destroy the person" do
      expect { procedure.reject! } .not_to change { procedure.person.discarded_at }
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      it "recovers the person" do
        expect { subject } .to change { procedure.person.discarded_at } .to(nil)
      end
      it "recovers the person state" do
        expect { subject } .to change { procedure.person.state } .from("cancelled").to("enabled")
      end
    end
  end
end

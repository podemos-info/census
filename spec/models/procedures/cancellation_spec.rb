# frozen_string_literal: true

require "rails_helper"

describe Procedures::Cancellation, :db do
  subject(:procedure) { create(:cancellation, :ready_to_process) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is auto_acceptable" do
    is_expected.to be_auto_acceptable
  end

  context "when accepted" do
    it "destroys the person" do
      expect { procedure.accept! } .to change { procedure.person.deleted_at } .from(nil)
    end
  end

  context "when rejected" do
    it "doesn't destroy the person" do
      expect { procedure.reject! } .not_to change { procedure.person.deleted_at }
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      it "recovers the person" do
        expect { subject } .to change { procedure.person.deleted_at } .to(nil)
      end
    end
  end
end

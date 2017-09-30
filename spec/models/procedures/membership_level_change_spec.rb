# frozen_string_literal: true

require "rails_helper"

describe Procedures::MembershipLevelChange, :db do
  let!(:person) { create(:person, :verified) }
  let(:procedure) { create(:membership_level_change, :ready_to_process, person: person, to_level: "member") }

  subject { procedure }

  it { is_expected.to be_valid }

  it "#acceptable? returns true" do
    expect(procedure.acceptable?).to be_truthy
  end

  it "acceptance changes person level" do
    expect { procedure.accept! } .to change { Person.find(person.id).level } .from("person").to("member")
  end

  it "rejection does not changes person level" do
    expect { procedure.reject! } .to_not change { Person.find(person.id).level }
  end

  context "when the target level is not allowed" do
    let!(:person) { create(:person) }

    it "#acceptable? returns false" do
      expect(procedure.acceptable?).to be_falsey
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      before do
        procedure.accept!
      end

      it "undo revert person level to previous value" do
        expect { procedure.undo! } .to change { Person.find(person.id).level } .from("member").to("person")
      end
    end

    context "after rejecting the procedure" do
      before do
        procedure.reject!
      end

      it "undo does not change person level" do
        expect { procedure.undo! } .to_not change { Person.find(person.id).level }
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Procedures::MembershipLevelChange, :db do
  let!(:person) { create(:person, :verified) }
  let(:procedure) { create(:membership_level_change, person: person, to_level: "member") }

  subject { procedure }

  it { is_expected.to be_valid }

  it "#check_acceptable returns true" do
    expect(procedure.check_acceptable).to be_truthy
  end

  it "acceptance changes person level" do
    expect { procedure.accept } .to change { Person.find(person.id).level } .from("person").to("member")
  end

  context "after accepting the procedure" do
    before do
      procedure.accept
    end

    it "undo revert person level to previous value" do
      expect { procedure.undo } .to change { Person.find(person.id).level } .from("member").to("person")
    end
  end

  context "when the target level is not allowed" do
    let!(:person) { create(:person) }

    it "#check_acceptable returns false" do
      expect(procedure.check_acceptable).to be_falsey
    end
  end
end

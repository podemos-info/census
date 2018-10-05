# frozen_string_literal: true

require "rails_helper"

describe Procedures::PhoneVerification, :db do
  subject(:procedure) { create(:phone_verification, :ready_to_process, person: person) }

  let!(:person) { create(:person) }

  it { is_expected.to be_valid }
  it { is_expected.to be_acceptable }
  it { is_expected.to be_auto_processable }

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    it "changes person phone verification status" do
      expect { subject } .to change { Person.find(person.id).phone_verified? } .from(false).to(true)
    end
  end

  context "when rejected" do
    subject(:rejecting) { procedure.reject! }

    it "does not change person verification status" do
      expect { subject } .not_to change { Person.find(person.id).phone_verified? }
    end
  end

  with_versioning do
    context "when has accepted the procedure" do
      before do
        procedure.accept!
      end

      it "undo revert person membership level to previous value" do
        expect { procedure.undo! } .to change { Person.find(person.id).phone_verified? } .from(true).to(false)
      end
    end

    context "when has rejected the procedure" do
      before do
        procedure.reject!
      end

      it "undo does not change person membership level" do
        expect { procedure.undo! } .not_to change { Person.find(person.id).phone_verified? }
      end
    end
  end
end

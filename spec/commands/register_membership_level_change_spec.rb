# frozen_string_literal: true

require "rails_helper"

describe Procedures::RegisterMembershipLevelChange do
  let!(:person) { create(:person) }
  let(:to_level) { "member" }

  subject do
    described_class.call(person, to_level)
  end

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to change the person level" do
      expect { subject } .to change { Procedure.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:to_level) { person.level }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedure.count }
    end
  end
end

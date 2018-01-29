# frozen_string_literal: true

require "rails_helper"

describe Procedures::CreateMembershipLevelChange do
  subject(:create_membership_level_change) { described_class.call(form) }

  let!(:person) { create(:person) }
  let(:membership_level) { "member" }
  let(:form_class) { People::MembershipLevelForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      membership_level: membership_level
    )
  end

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to change the person membership level" do
      expect { subject } .to change { Procedure.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedure.count }
    end
  end
end

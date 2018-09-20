# frozen_string_literal: true

require "rails_helper"

describe People::CreateMembershipLevelChange do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::MembershipLevelForm }
  let(:valid) { true }
  let(:has_changes?) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      membership_level: membership_level,
      has_changes?: has_changes?
    )
  end

  let(:membership_level) { "member" }

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to change the person membership level" do
      expect { subject } .to change(Procedures::MembershipLevelChange, :count).by(1)
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .not_to change(Procedures::MembershipLevelChange, :count)
    end
  end

  context "when has no changes" do
    let(:has_changes?) { false }

    it "broadcasts :noop" do
      expect { subject } .to broadcast(:noop)
    end

    it "doesn't create the new procedure" do
      expect { subject } .not_to change(Procedures::MembershipLevelChange, :count)
    end
  end

  context "when a procedure already exists for the person" do
    before { procedure }

    let(:procedure) { create(:membership_level_change, person: person) }

    it "does not create a new procedure" do
      expect { subject } .not_to change(Procedures::MembershipLevelChange, :count)
    end
  end
end

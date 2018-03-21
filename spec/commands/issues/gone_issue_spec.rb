# frozen_string_literal: true

require "rails_helper"

describe Issues::GoneIssue do
  subject(:command) { described_class.call(issue: issue, admin: admin) }

  let!(:issue) { create(:duplicated_document) }
  let!(:admin) { create(:admin) }

  describe "when is ok" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "changes the issue assigned_to field" do
      expect { subject } .to change { issue.assigned_to } .to(admin.person)
    end

    it "saves the closed_at field" do
      expect { subject } .to change { issue.closed_at } .from(nil)
    end

    it "saves the close result as gone" do
      expect { subject } .to change { issue.close_result } .from(nil).to("gone")
    end
  end

  describe "when the issue was previously assigned" do
    before do
      issue.assigned_to = create(:person)
      issue.save!
    end

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "doesn't changes the issue assigned_to field" do
      expect { subject } .not_to change { issue.assigned_to }
    end

    it "saves the closed_at field" do
      expect { subject } .to change { issue.closed_at } .from(nil)
    end

    it "saves the close result as gone" do
      expect { subject } .to change { issue.close_result } .from(nil).to("gone")
    end
  end
end

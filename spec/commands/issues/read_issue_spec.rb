# frozen_string_literal: true

require "rails_helper"

describe Issues::ReadIssue do
  subject(:command) { described_class.call(issue: issue_unread.issue, admin: issue_unread.admin) }

  let!(:issue_unread) { create(:issue_unread) }

  describe "when there is an unread issue" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "deletes the issue unread" do
      expect { subject } .to change { IssueUnread.count } .by(-1)
    end
  end

  describe "when there is not an unread issue" do
    before do
      issue_unread.destroy
    end

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "can't delete the issue unread" do
      expect { subject } .not_to change { IssueUnread.count }
    end
  end
end

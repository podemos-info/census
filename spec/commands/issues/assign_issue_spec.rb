# frozen_string_literal: true

require "rails_helper"

describe Issues::AssignIssue do
  subject(:command) { described_class.call(issue: issue, admin: admin) }

  let!(:issue) { create(:duplicated_document) }
  let!(:admin) { create(:admin) }

  context "when is ok" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "changes the issue assigned_to field" do
      expect { subject } .to change(issue, :assigned_to).to(admin.person)
    end
  end
end

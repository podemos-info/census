# frozen_string_literal: true

require "rails_helper"

describe Issues::FixIssue do
  subject(:command) { described_class.call(issue: issue, admin: admin) }
  before(:each) { issue.chosen_person_id = chosen_person_id }

  let(:issue) { create(:duplicated_document) }
  let(:admin) { create(:admin) }
  let(:chosen_person_id) { issue.procedure.person_id }

  describe "when is ok" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "changes the issue assigned_to field" do
      expect { subject } .to change { Issue.find(issue.id).assigned_to } .to(admin.person)
    end

    it "saves the closed_at field" do
      expect { subject } .to change { Issue.find(issue.id).closed_at } .from(nil)
    end

    it "saves the close result as fixed" do
      expect { subject } .to change { Issue.find(issue.id).close_result } .from(nil).to("fixed")
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
      expect { subject } .not_to change { Issue.find(issue.id).assigned_to }
    end

    it "saves the closed_at field" do
      expect { subject } .to change { Issue.find(issue.id).closed_at } .from(nil)
    end

    it "saves the close result as fixed" do
      expect { subject } .to change { Issue.find(issue.id).close_result } .from(nil).to("fixed")
    end
  end

  describe "when the fix information is invalid" do
    let(:chosen_person_id) { create(:person).id }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't changes the issue assigned_to field" do
      expect { subject } .not_to change { Issue.find(issue.id).assigned_to }
    end

    it "doesn't save the closed_at field" do
      expect { subject } .not_to change { Issue.find(issue.id).closed_at } .from(nil)
    end

    it "doesn't save  the close result as fixed" do
      expect { subject } .not_to change { Issue.find(issue.id).close_result } .from(nil)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Issues::CheckPersonIssues do
  subject(:command) { described_class.call(person: person, admin: admin) }

  let(:person) { create(:person) }
  let(:admin) { create(:admin) }

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change { Issue.count }
    end
  end

  describe "when another person with same document exists" do
    let!(:same_person) { create(:person, :copy, from: person) }

    it "broadcast :new_issue" do
      expect { subject } .to broadcast(:new_issue)
    end

    it "creates a new issue" do
      expect { subject } .to change { Issue.count } .by(1)
    end

    it "relate the person to the new issue" do
      subject
      expect(Issue.last.people).to contain_exactly(person, same_person)
    end
  end

  describe "when an unfixed issue for this document exists" do
    let!(:same_person) { create(:person, :copy, from: person) }
    let(:more_people) { create(:person, :copy, from: person) }
    before do
      described_class.call(person: person, admin: admin)
      more_people
    end

    it "broadcast :existing_issue" do
      expect { subject } .to broadcast(:existing_issue)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change { Issue.count }
    end

    it "relate the person to the existing issue" do
      subject
      expect(Issue.last.people).to contain_exactly(person, same_person, more_people)
    end
  end

  describe "when an unfixed issue for this document existed, but is fixed now" do
    let!(:same_person) { create(:person, :copy, from: person) }
    let(:other_person) { build(:person) }
    before do
      described_class.call(person: person, admin: admin)
      same_person.update_attributes(document_id: other_person.document_id)
    end

    it "broadcast :fixed_issue" do
      expect { subject } .to broadcast(:fixed_issue)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change { Issue.count }
    end

    it "fixes the existing issue" do
      expect { subject } .to change { Issue.last.fixed_at } .from(nil)
    end

    it "keeps the issue related objects before fixing it" do
      expect { subject } .not_to change { Issue.last.people }
    end
  end
end

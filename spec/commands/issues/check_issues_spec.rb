# frozen_string_literal: true

require "rails_helper"

describe Issues::CheckIssues do
  subject(:command) { described_class.call(issuable: procedure, admin: admin) }

  let(:procedure) { create(:registration, person_copy_data: person) }
  let(:person) { build(:person) }
  let(:admin) { create(:admin) }

  context "when valid" do
    it "broadcasts :no_issues" do
      expect { subject } .to broadcast(:no_issue)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change(Issue, :count)
    end
  end

  context "when another person with same document exists" do
    let!(:same_person) { create(:person, :copy, from: person) }

    it "broadcast :new_issue" do
      expect { subject } .to broadcast(:new_issue)
    end

    it "creates a duplicated document issue" do
      expect { subject } .to change { Issues::People::DuplicatedDocument.count } .by(1)
    end

    it "relate the procedure to the new issue" do
      subject
      expect(Issues::People::DuplicatedDocument.last.procedures).to contain_exactly(procedure)
    end

    it "relate the existing person to the new issue" do
      subject
      expect(Issues::People::DuplicatedDocument.last.people).to contain_exactly(procedure.person, same_person)
    end
  end

  context "when an unfixed issue for this document exists" do
    before do
      same_person
      described_class.call(issuable: procedure, admin: admin)
      more_people
    end

    let(:same_person) { create(:person, :copy, from: person) }
    let(:more_people) { create(:person, :copy, from: person) }

    it "broadcast :existing_issue" do
      expect { subject } .to broadcast(:existing_issue)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change(Issue, :count)
    end

    it "relate the person to the existing issue" do
      subject
      expect(Issues::People::DuplicatedDocument.last.people).to contain_exactly(procedure.person, same_person, more_people)
    end
  end

  context "when an unfixed issue for this document existed, but is fixed now" do
    before do
      same_person
      described_class.call(issuable: procedure, admin: admin)
      same_person.update!(document_id: other_person.document_id)
    end

    let(:same_person) { create(:person, :copy, from: person) }
    let(:other_person) { build(:person) }

    it "broadcast :gone_issue" do
      expect { subject } .to broadcast(:gone_issue)
    end

    it "doesn't create new issues" do
      expect { subject } .not_to change(Issue, :count)
    end

    it "closes the existing issue" do
      expect { subject } .to change { Issue.last.closed_at } .from(nil)
    end

    it "keeps the issue related objects before fixing it" do
      expect { subject } .not_to change { Issue.last.person_ids }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe "Fix Issues", type: :system do
  let(:current_admin) { create(:admin, :lopd) }

  before do
    login_as current_admin
    visit edit_issue_path(issue)
  end

  context "when fixing a single person issue" do
    let(:issue) { create(:untrusted_email) }
    let(:procedure) { issue.procedures.first }
    let(:procedure_person) { procedure.person }

    it "fixes the issue marking the email as untrusted" do
      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, procedure, procedure_person].each(&:reload)

      expect(issue).to be_fixed
      expect(procedure).to be_rejected
      expect(procedure_person).to be_rejected
    end

    it "fixes the issue marking the email as trusted" do
      find("label[for=issue_trusted]").click

      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, procedure, procedure_person].each(&:reload)

      expect(issue).to be_fixed
      expect(procedure).to be_accepted
      expect(procedure_person).to be_enabled
    end
  end

  context "when fixing an issue with related issues" do
    let(:issue) { create(:duplicated_document, issuable: procedure, other_person: existing_person) }
    let!(:other_issue) { create(:duplicated_person, issuable: procedure, other_person: existing_person) }
    let(:procedure) { create(:registration, person_copy_data: existing_person) }
    let(:procedure_person) { procedure.person }
    let(:existing_person) { create(:person) }

    it "fixes the issue choosing the existing person" do
      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, other_issue, procedure, existing_person, procedure_person].each(&:reload)

      expect(issue).to be_fixed
      expect(other_issue).to be_gone
      expect(procedure).to be_rejected
      expect(existing_person).to be_enabled
      expect(procedure_person).to be_rejected
    end

    it "fixes the issue choosing the procedure person" do
      find("label[for=issue_chosen_person_id_#{procedure_person.id}]").click

      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, other_issue, procedure, existing_person, procedure_person].each(&:reload)

      expect(issue).to be_fixed
      expect(other_issue).to be_gone
      expect(procedure).to be_accepted
      expect(existing_person).to be_banned
      expect(procedure_person).to be_enabled
    end
  end
end

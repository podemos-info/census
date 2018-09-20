# frozen_string_literal: true

require "rails_helper"

describe "Fix Issues", type: :system do
  let(:current_admin) { create(:admin, :data) }

  before do
    login_as current_admin
    visit edit_issue_path(issue)
  end

  context "when fixing a single person issue" do
    before do
      find("label[for=issue_trusted]").click if trusted

      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, procedure, procedure_person].each(&:reload)
    end

    let(:trusted) { true }
    let(:issue) { create(:untrusted_email) }
    let(:procedure) { issue.procedures.first }
    let(:procedure_person) { procedure.person }

    it { expect(issue).to be_fixed }
    it { expect(procedure).to be_accepted }
    it { expect(procedure_person).to be_enabled }

    context "when marking as untrusted" do
      let(:trusted) { false }

      it { expect(issue).to be_fixed }
      it { expect(procedure).to be_dismissed }
      it { expect(procedure_person).to be_trashed }
    end
  end

  context "when fixing an issue with related issues" do
    before do
      issue && other_issue

      find("label[for=issue_cause_mistake]").click
      find("label[for=issue_chosen_person_id_#{procedure_person.id}]").click if choosing_procedure_person
      perform_enqueued_jobs do
        find("*[type=submit]").click
      end

      [issue, other_issue, procedure, existing_person, procedure_person].each(&:reload)
    end

    let(:choosing_procedure_person) { true }
    let(:issue) { create(:duplicated_document, issuable: procedure, other_person: existing_person) }
    let(:other_issue) { create(:duplicated_person, issuable: procedure, other_person: existing_person) }
    let(:procedure) { create(:registration, person_copy_data: existing_person) }
    let(:procedure_person) { procedure.person }
    let(:existing_person) { create(:person) }

    it { expect(issue).to be_fixed }
    it { expect(other_issue).to be_gone }
    it { expect(procedure).to be_accepted }
    it { expect(existing_person).to be_trashed }
    it { expect(procedure_person).to be_enabled }

    context "when choosing the existing person" do
      let(:choosing_procedure_person) { false }

      it { expect(issue).to be_fixed }
      it { expect(other_issue).to be_gone }
      it { expect(procedure).to be_dismissed }
      it { expect(existing_person).to be_enabled }
      it { expect(procedure_person).to be_trashed }
    end
  end
end

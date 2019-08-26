# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  subject(:procedure) { create(:registration) }

  let(:other_admin) { create(:admin) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_undoable }

  it "permitted events returns accept, set_issues and reject" do
    expect(subject.permitted_events(other_admin)).to contain_exactly(:accept, :reject, :dismiss)
  end

  with_versioning do
    describe "undoable procedures" do
      subject(:procedure) { create(:membership_level_change, :undoable, person: create(:person, :verified)) }

      it { is_expected.to be_undoable }
      it { is_expected.to be_undoable_by(subject.processed_by) }
      it { is_expected.not_to be_undoable_by(other_admin) }

      it "permitted events returns undo" do
        expect(subject.permitted_events(subject.processed_by)).to contain_exactly(:undo)
      end

      it "has an undo version" do
        expect(subject.undo_version).to be_present
      end
    end
  end

  context "with all descendants" do
    described_class.descendants.each do |procedure_class|
      describe "#{procedure_class} implements abstract methods" do
        subject(:procedure) { procedure_class.new }

        it { is_expected.to respond_to(:process_accept) }
        it { is_expected.to respond_to(:undo_accept) }
        it { is_expected.to respond_to(:persist_accept_changes!) }
        it { is_expected.to respond_to(:acceptable?) }
      end
    end
  end

  describe "#issues_summary" do
    subject(:method) { procedure.issues_summary }

    it { is_expected.to eq(:ok) }

    context "when has pending issues" do
      before { issue }

      let(:issue) { create(:duplicated_document, issuable: procedure) }

      it { is_expected.to eq(:pending) }
    end

    context "when has unrecoverable issues" do
      before { issue && issue2 }

      let(:issue) { create(:duplicated_document, issuable: procedure) }
      let(:issue2) { create(:duplicated_document, :ready_to_fix, :fixed, issuable: procedure, chosen_person_id: create(:person).id) }

      it { is_expected.to eq(:unrecoverable) }
    end

    context "when has fixed issues" do
      before { issue }

      let(:issue) { create(:duplicated_document, :ready_to_fix, :fixed, issuable: procedure, chosen_person_id: procedure.person.id) }

      it { is_expected.to eq(:ok) }
    end
  end

  it_behaves_like(
    "a model that allows fast filter",
    first_name: ->(person) { person.first_name },
    last_names: ->(person) { [person.last_name1, person.last_name2].join(" ") },
    document: ->(person) { person.document_id },
    phone_number: ->(person) { person.phone },
    phone_number_begining: ->(person) { person.phone[0..6] }
  ) do
    let(:resource) { create(:registration, person: person, person_copy_data: person) }
    let(:person) { create(:person) }
  end
end

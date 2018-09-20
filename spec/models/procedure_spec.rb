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

  context "with dependent procedure (acceptable only after the parent)" do
    let(:processed_by) { nil }
    let(:parent_procedure) { create(:document_verification) }
    let(:person) { parent_procedure.person }
    let!(:child_procedure) { build(:membership_level_change, depends_on: parent_procedure, person: person, processed_by: processed_by) }

    it { is_expected.to be_valid }

    context "with the parent procedure" do
      subject(:procedure) { parent_procedure }

      before { child_procedure.save }

      it { is_expected.to be_full_acceptable_by(other_admin) }
    end

    context "with the child procedure" do
      subject(:procedure) { child_procedure }

      it { is_expected.not_to be_acceptable }

      context "when affecting other person" do
        let(:person) { create(:person) }

        it { is_expected.to be_invalid }
      end

      context "when processed by the affected person" do
        let(:processed_by) { create(:admin, person: person) }

        it { is_expected.to be_invalid }
        it { is_expected.not_to be_full_acceptable_by(processed_by) }
      end
    end
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

      context "with dependent procedure" do
        subject(:procedure) { create(:document_verification, :undoable, person: create(:person)) }

        before { child_procedure }

        let(:child_procedure) { create(:membership_level_change, depends_on: procedure, person: procedure.person) }

        it { is_expected.to be_full_undoable_by(procedure.processed_by) }
        it { is_expected.not_to be_full_undoable_by(other_admin) }

        it "permitted events returns undo" do
          expect(subject.permitted_events(subject.processed_by)).to contain_exactly(:undo)
        end
      end
    end
  end

  context "with all descendants" do
    Procedure.descendants.each do |procedure_class|
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
end

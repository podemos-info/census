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

    context "#full_acceptable_by? returns true" do
      before { child_procedure.save }
      subject(:procedure) { parent_procedure }
      it { expect(subject.full_acceptable_by?(other_admin)).to be_truthy }
    end

    context "#acceptable? in the child procedure returns false" do
      subject(:procedure) { child_procedure }
      it { is_expected.not_to be_acceptable }
    end

    context "must affect to the same people" do
      subject(:procedure) { child_procedure }
      let(:person) { create(:person) }

      it { is_expected.to be_invalid }
    end

    context "can't be processed by the affected person" do
      subject(:procedure) { child_procedure }
      let(:processed_by) { create(:admin, person: person) }

      it { is_expected.to be_invalid }
      it { expect(procedure.full_acceptable_by?(processed_by)).to be_falsey }
    end
  end

  with_versioning do
    context "undoable" do
      subject(:procedure) { create(:membership_level_change, :undoable, person: create(:person, :verified)) }

      it { is_expected.to be_undoable }

      it "permitted events returns undo" do
        expect(subject.permitted_events(subject.processed_by)).to contain_exactly(:undo)
      end

      it "is undoable by the same person that processed it" do
        expect(subject.undoable_by?(subject.processed_by)).to be_truthy
      end

      it "is not undoable by other person that the one processed it" do
        expect(subject.undoable_by?(other_admin)).to be_falsey
      end

      it "has an undo version" do
        expect(subject.undo_version).to be_present
      end

      context "with dependent procedure" do
        subject(:procedure) { create(:document_verification, :undoable, person: create(:person)) }
        let!(:child_procedure) { create(:membership_level_change, depends_on: procedure, person: procedure.person) }

        it "permitted events returns undo" do
          expect(subject.permitted_events(subject.processed_by)).to contain_exactly(:undo)
        end

        it "is fully undoable by the same person that processed it" do
          expect(subject.full_undoable_by?(procedure.processed_by)).to be_truthy
        end

        it "is not fully undoable by other person that the one processed it" do
          expect(subject.full_undoable_by?(other_admin)).to be_falsey
        end
      end
    end
  end

  context "all descendants implement abstract methods" do
    Procedure.descendants.each do |procedure_class|
      next if procedure_class == Procedures::PersonDataProcedure

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
      let!(:issue) { create(:duplicated_document, issuable: procedure) }

      it { is_expected.to eq(:pending) }
    end

    context "when has unrecoverable issues" do
      let!(:issue) { create(:duplicated_document, issuable: procedure) }
      let!(:issue2) { create(:duplicated_document, :ready_to_fix, :fixed, issuable: procedure, chosen_person_id: create(:person).id) }

      it { is_expected.to eq(:unrecoverable) }
    end

    context "when has fixed issues" do
      let!(:issue) { create(:duplicated_document, :ready_to_fix, :fixed, issuable: procedure, chosen_person_id: procedure.person.id) }

      it { is_expected.to eq(:ok) }
    end
  end
end

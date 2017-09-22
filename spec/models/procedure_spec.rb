# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  let(:other_person) { create(:person) }
  let(:procedure) { build(:membership_level_change) }

  subject { procedure }

  it { is_expected.to be_valid }

  it "is not undoable" do
    expect(subject.undoable?).to be_falsey
  end

  context "with dependent procedure (acceptable only after the parent)" do
    let(:processed_by) { nil }
    let(:parent_procedure) { create(:verification_document) }
    let(:person) { parent_procedure.person }
    let(:child_procedure) { build(:membership_level_change, depends_on: parent_procedure, person: person, processed_by: processed_by) }

    it { is_expected.to be_valid }

    context "#full_acceptable_by? returns true" do
      let(:procedure) { parent_procedure }
      it { expect(procedure.full_acceptable_by?(other_person)).to be_truthy }
    end

    context "#acceptable? in the child procedure returns false" do
      let(:procedure) { child_procedure }
      it { expect(procedure.acceptable?).to be_falsey }
    end

    context "must affect to the same people" do
      let(:person) { create(:person) }
      let(:procedure) { child_procedure }

      it { is_expected.to be_invalid }
    end

    context "can't be processed by the affected person" do
      let(:processed_by) { create(:admin, person: person) }
      let(:procedure) { child_procedure }

      it { is_expected.to be_invalid }
      it { expect(procedure.full_acceptable_by?(processed_by)).to be_falsey }
    end
  end

  context "undoable" do
    let(:procedure) { create(:membership_level_change, :undoable, person: create(:person, :verified)) }

    it "is undoable" do
      expect(subject.undoable?).to be_truthy
    end

    it "is undoable by the same person that processed it" do
      expect(subject.undoable_by?(subject.processed_by)).to be_truthy
    end

    it "is not undoable by other person that the one processed it" do
      expect(subject.undoable_by?(other_person)).to be_falsey
    end

    it "has an undo version" do
      expect(subject.undo_version).to be_present
    end

    context "with dependent procedure" do
      let(:procedure) { create(:verification_document, :undoable, person: create(:person, :verified)) }
      let!(:child_procedure) { create(:membership_level_change, depends_on: procedure, person: procedure.person) }

      it "is fully undoable by the same person that processed it" do
        expect(subject.full_undoable_by?(procedure.processed_by)).to be_truthy
      end

      it "is not fully undoable by other person that the one processed it" do
        expect(subject.full_undoable_by?(other_person)).to be_falsey
      end
    end
  end

  context "all descendants implement abstract methods" do
    Dir["app/models/procedures/*.rb"].each do |file|
      require_dependency File.expand_path(file)
    end

    Procedure.descendants.each do |procedure_class|
      describe "#{procedure_class} implements abstract methods" do
        let(:procedure) { procedure_class.new }
        it { is_expected.to respond_to(:process_accept) }
        it { is_expected.to respond_to(:undo_accept) }
        it { is_expected.to respond_to(:persist_accept_changes!) }
        it { is_expected.to respond_to(:acceptable?) }
      end
    end
  end
end

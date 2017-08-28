# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  let(:procedure) { build(:membership_level_change) }

  subject { procedure }

  it { is_expected.to be_valid }

  it "is not undoable" do
    expect(subject.undoable?).to be_falsey
  end

  context "with dependent procedure (acceptable only after the parent)" do
    let(:processor) { nil }
    let(:parent_procedure) { create(:verification_document) }
    let(:person) { parent_procedure.person }
    let(:child_procedure) { build(:membership_level_change, depends_on: parent_procedure, person: person, processed_by: processor) }

    it { is_expected.to be_valid }

    context "#full_acceptable? returns true" do
      let(:procedure) { parent_procedure }
      it { expect(procedure.full_acceptable?).to be_truthy }
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
      let(:processor) { person }
      let(:procedure) { child_procedure }

      it { is_expected.to be_invalid }
    end
  end

  context "undoable" do
    let(:other_person) { create(:person) }
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
end

# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  let(:procedure) { build(:membership_level_change) }

  subject { procedure }

  it { is_expected.to be_valid }

  it "is not undoable" do
    expect(subject.undoable?).to be_falsey
  end

  context "with dependent procedure" do
    let(:processor) { nil }
    let(:parent_procedure) { build(:verification_document) }
    let(:person) { parent_procedure.person }
    let(:procedure) { build(:membership_level_change, depends_on: parent_procedure, person: person, processed_by: processor) }

    it { is_expected.to be_valid }

    context "must affect to the same people" do
      let(:person) { build(:person) }

      it { is_expected.to be_invalid }
    end

    context "can't be processed by the affected person" do
      let(:processor) { person }

      it { is_expected.to be_invalid }
    end
  end

  context "undoable" do
    let(:other_person) { create(:person) }
    let(:procedure) { create(:membership_level_change, :undoable) }

    it "is undoable" do
      expect(subject.undoable?).to be_truthy
    end

    it "is undoable by the same person that processed it" do
      expect(subject.undoable?(subject.processed_by)).to be_truthy
    end

    it "is not undoable by other person that the one processed it" do
      expect(subject.undoable?(other_person)).to be_falsey
    end

    it "has an undo version" do
      expect(subject.undo_version).to be_present
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Procedure, :db do
  let(:procedure) { build(:membership_level_change) }

  subject { procedure }

  it { is_expected.to be_valid }

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
end

# frozen_string_literal: true

require "rails_helper"

describe People::PersonDataChangeForm do
  subject(:form) { described_class.new(person_id: person.id, **person_data) }

  let(:person) { create(:person) }
  let(:person_data) { { first_name: "changed" } }

  it { is_expected.to be_valid }

  context "when invalid gender" do
    let(:person_data) { { gender: "potato" } }

    it { is_expected.to be_invalid }
  end

  context "when changing document id" do
    let(:person) { create(:person, document_type: :dni) }

    context "with a valid document id" do
      let(:person_data) { { document_id: "1R" } }

      it { is_expected.to be_valid }
    end

    context "with an invalid document id" do
      let(:person_data) { { document_id: "123" } }

      it { is_expected.to be_invalid }
    end
  end

  context "when changing document type to dni" do
    let(:person) { create(:person, document_type: :passport, document_scope: create(:scope), document_id: "ABC1234") }

    context "without setting the local scope" do
      let(:person_data) { { document_type: :dni, document_id: "1R" } }

      it { is_expected.to be_invalid }
    end

    context "without setting a valid document id" do
      let(:person_data) { { document_type: :dni, document_scope_code: "ES" } }

      it { is_expected.to be_invalid }
    end

    context "when setting a valid document id and the local scope" do
      let(:person_data) { { document_type: :dni, document_scope_code: "ES", document_id: "1R" } }

      it { is_expected.to be_valid }
    end
  end
end

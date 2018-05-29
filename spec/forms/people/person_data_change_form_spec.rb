# frozen_string_literal: true

require "rails_helper"

describe People::PersonDataChangeForm do
  subject(:form) { described_class.new(person_id: person.id, **changes) }

  let(:person) { create(:person) }
  let(:changes) { { first_name: "changed" } }

  it { is_expected.to be_valid }

  context "when changing gender" do
    context "with a blank gender" do
      let(:changes) { { gender: "" } }

      it { is_expected.to be_invalid }
    end

    context "with an invalid gender" do
      let(:changes) { { gender: "potato" } }

      it { is_expected.to be_invalid }
    end
  end

  context "when changing document id" do
    let(:person) { create(:person, document_type: :dni) }

    context "with a valid document id" do
      let(:changes) { { document_id: "1R" } }

      it { is_expected.to be_valid }
    end

    context "with an invalid document id" do
      let(:changes) { { document_id: "123" } }

      it { is_expected.to be_invalid }
    end

    context "with a blank document id" do
      let(:changes) { { document_id: "" } }

      it { is_expected.to be_invalid }
    end
  end

  context "when changing document type" do
    let(:person) { create(:person, document_type: :passport, document_scope: create(:scope), document_id: "ABC1234") }

    context "with a blank document type" do
      let(:changes) { { document_type: "" } }

      it { is_expected.to be_invalid }
    end

    context "without setting the local scope" do
      let(:changes) { { document_type: :dni, document_id: "1R" } }

      it { is_expected.to be_invalid }
    end

    context "without setting a valid document id" do
      let(:changes) { { document_type: :dni, document_scope_code: "ES" } }

      it { is_expected.to be_invalid }
    end

    context "without setting a valid document type" do
      let(:changes) { { document_type: :dani, document_scope_code: "ES", document_id: "1R" } }

      it { is_expected.to be_invalid }
    end

    context "when setting a valid document id and the local scope" do
      let(:changes) { { document_type: :dni, document_scope_code: "ES", document_id: "1R" } }

      it { is_expected.to be_valid }
    end
  end

  describe "#has_changes?" do
    it { is_expected.to have_changes }

    context "when there are no changed attributes" do
      let(:changes) { {} }

      it { is_expected.not_to have_changes }
    end

    context "when the changed attributes have the same value" do
      let(:changes) { { first_name: person.first_name } }

      it { is_expected.not_to have_changes }
    end

    context "when the changed attributes is a scope" do
      let(:changes) { { scope_code: create(:scope).code } }

      it { is_expected.to have_changes }
    end
  end

  describe "#changed_data" do
    subject(:changed_data) { form.changed_data }

    context "when there are no changed attributes" do
      let(:changes) { {} }

      it { is_expected.to eq({}) }
    end

    context "when the changed attributes have the same value" do
      let(:changes) { { first_name: person.first_name } }

      it { is_expected.to eq({}) }
    end

    context "when the changed attributes are a scope" do
      let(:changes) { { scope_code: scope.code } }
      let(:scope) { create(:scope) }

      it "includes the scope id field" do
        is_expected.to eq(scope_id: scope.id)
      end
    end

    context "when the changed attributes are a document attribute" do
      let(:person) { create(:person, document_type: "dni") }
      let(:changes) { { document_type: "passport" } }

      it "includes all the document fields" do
        is_expected.to eq(document_type: "passport", document_id: person.document_id, document_scope_id: person.document_scope.id)
      end
    end
  end
end

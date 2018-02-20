# frozen_string_literal: true

require "rails_helper"

describe People::RegistrationForm do
  subject(:form) do
    described_class.new(
      first_name: first_name,
      last_name1: last_name1,
      last_name2: last_name2,
      document_type: document_type,
      document_id: document_id,
      document_scope_code: document_scope_code,
      born_at: born_at,
      gender: gender,
      address: address,
      address_scope_code: address_scope_code,
      postal_code: postal_code,
      scope_code: scope_code,
      email: email,
      phone: phone
    )
  end

  let(:person) { build(:person) }

  let(:scope) { create(:scope) }
  let(:address_scope) { create(:scope) }
  let(:document_scope) { person.document_scope }

  let(:first_name) { person.first_name }
  let(:last_name1) { person.last_name1 }
  let(:last_name2) { person.last_name2 }
  let(:document_type) { person.document_type }
  let(:document_id) { person.document_id }
  let(:document_scope_code) { document_scope.code }
  let(:born_at) { person.born_at }
  let(:gender) { person.gender }
  let(:address) { person.address }
  let(:address_scope_code) { address_scope.code }
  let(:postal_code) { person.postal_code }
  let(:scope_code) { scope.code }
  let(:email) { person.email }
  let(:phone) { person.phone }

  it { is_expected.to be_valid }

  context "with an empty first name" do
    let(:first_name) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  describe "email" do
    context "with an empty email" do
      let(:email) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end

  context "when setting document type to dni" do
    let(:person) { create(:person, document_type: :passport, document_scope: create(:scope), document_id: "ABC1234") }

    context "without setting the local scope" do
      let(:document_type) { :dni }
      let(:document_id) { "1R" }
      let(:document_scope_code) { "US" }

      it { is_expected.to be_invalid }
    end

    context "without setting a valid document id" do
      let(:document_type) { :dni }
      let(:document_id) { "1234" }
      let(:document_scope_code) { "ES" }

      it { is_expected.to be_invalid }
    end

    context "when setting a valid document id and the local scope" do
      let(:document_type) { :dni }
      let(:document_id) { "1R" }
      let(:document_scope_code) { "ES" }

      it { is_expected.to be_valid }
    end
  end
end
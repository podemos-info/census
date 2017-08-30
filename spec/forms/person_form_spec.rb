# frozen_string_literal: true

require "rails_helper"

describe PersonForm do
  let(:person) { build(:person) }

  subject do
    described_class.new(
      level: level,
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
      phone: phone,
      extra: extra,
      files: files
    )
  end

  let(:level) { person.level }
  let(:files) do
    attachment = build(:attachment)
    [api_attachment_format(attachment), api_attachment_format(attachment)]
  end

  let(:first_name) { person.first_name }
  let(:last_name1) { person.last_name1 }
  let(:last_name2) { person.last_name2 }
  let(:document_type) { person.document_type }
  let(:document_id) { person.document_id }
  let(:document_scope_code) { person.document_scope.code }
  let(:born_at) { person.born_at }
  let(:gender) { person.gender }
  let(:address) { person.address }
  let(:address_scope_code) { person.address_scope.code }
  let(:postal_code) { person.postal_code }
  let(:scope_code) { person.scope.code }
  let(:email) { person.email }
  let(:phone) { person.phone }
  let(:extra) { person.extra }

  context "with correct data" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

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
end

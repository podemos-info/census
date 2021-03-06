# frozen_string_literal: true

require "rails_helper"

describe People::RegistrationForm do
  subject(:form) do
    described_class.new(
      person_id: person_id,
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
      origin_qualified_id: origin_qualified_id
    )
  end

  let(:person) { create(:person) }
  let(:scope) { create(:scope) }
  let(:address_scope) { create(:scope) }
  let(:document_scope) { person.document_scope }

  let(:person_id) { nil }
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
  let(:origin_qualified_id) { person.qualified_id_at("participa2-1") }

  it { is_expected.to be_valid }

  context "with an empty first name" do
    let(:first_name) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  context "with an empty email" do
    let(:email) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  describe "document validation" do
    context "with a missing document type" do
      let(:document_type) { nil }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "adds a single error" do
        subject.valid?

        expect(subject.errors[:document_type].count).to eq(1)
      end
    end

    context "with an empty document type" do
      let(:document_type) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "adds a single error" do
        subject.valid?

        expect(subject.errors[:document_type].count).to eq(1)
      end
    end

    context "with a missing document id" do
      let(:document_id) { nil }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "adds a single error" do
        subject.valid?

        expect(subject.errors[:document_id].count).to eq(1)
      end
    end

    context "with an empty document id" do
      let(:document_id) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "adds a single error" do
        subject.valid?

        expect(subject.errors[:document_id].count).to eq(1)
      end
    end
  end

  context "with a missing gender" do
    let(:gender) { nil }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "adds a single error" do
      subject.valid?

      expect(subject.errors[:gender].count).to eq(1)
    end
  end

  context "with an empty gender" do
    let(:gender) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "adds a single error" do
      subject.valid?

      expect(subject.errors[:gender].count).to eq(1)
    end
  end

  context "when user is already registered" do
    let(:person_id) { create(:person).id }

    it "is invalid" do
      expect(subject).not_to be_valid
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

  describe "postal code validation" do
    context "with an empty postal code" do
      let(:postal_code) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "adds a single error" do
        subject.valid?

        expect(subject.errors[:postal_code].count).to eq(1)
      end
    end

    context "when the user lives in a spanish province" do
      let(:address_scope) { create(:scope, code: "ES-CL-LE-211", parent: province) }
      let(:province) { create(:scope, code: "ES-CL-LE", mappings: { "INE-PROV" => "24" }) }

      context "when postal code is invalid" do
        let(:postal_code) { "01234" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end

        it "adds a single error" do
          subject.valid?

          expect(subject.errors[:postal_code].count).to eq(1)
        end
      end

      context "when postal code is valid" do
        let(:postal_code) { "24234" }

        it { is_expected.to be_valid }
      end
    end
  end
end

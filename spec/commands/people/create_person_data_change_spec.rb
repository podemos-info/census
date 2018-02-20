# frozen_string_literal: true

require "rails_helper"

describe People::CreatePersonDataChange do
  subject(:procedure) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::PersonDataChangeForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      first_name: first_name,
      last_name1: last_name1,
      last_name2: last_name2,
      document_type: document_type,
      document_id: document_id,
      born_at: born_at,
      gender: gender,
      address: address,
      postal_code: postal_code,
      email: email,
      phone: phone,
      scope: scope,
      address_scope: address_scope,
      document_scope: document_scope
    )
  end

  let(:first_name) { "changed" }
  let(:last_name1) { nil }
  let(:last_name2) { nil }
  let(:document_type) { nil }
  let(:document_id) { nil }
  let(:born_at) { nil }
  let(:gender) { nil }
  let(:address) { nil }
  let(:postal_code) { nil }
  let(:email) { nil }
  let(:phone) { nil }
  let(:scope) { nil }
  let(:address_scope) { nil }
  let(:document_scope) { nil }

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "create a new procedure to change the person data" do
      expect { subject } .to change { Procedures::PersonDataChange.count } .by(1)
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::PersonDataChange.count }
    end
  end
end

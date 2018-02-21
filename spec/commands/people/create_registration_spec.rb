# frozen_string_literal: true

require "rails_helper"

describe People::CreateRegistration do
  subject(:command) { described_class.call(form: form) }

  let(:person) { build(:person) }
  let(:form_class) { People::RegistrationForm }
  let(:valid) { true }
  let(:existing_person) { nil }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: existing_person,
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

  let(:first_name) { person.first_name }
  let(:last_name1) { person.last_name1 }
  let(:last_name2) { person.last_name2 }
  let(:document_type) { person.document_type }
  let(:document_id) { person.document_id }
  let(:born_at) { person.born_at }
  let(:gender) { person.gender }
  let(:address) { person.address }
  let(:postal_code) { person.postal_code }
  let(:email) { person.email }
  let(:phone) { person.phone }
  let(:scope) { person.scope }
  let(:address_scope) { person.address_scope }
  let(:document_scope) { person.document_scope }

  with_versioning do
    describe "when valid" do
      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "create a new person" do
        expect { subject } .to change { Person.count } .by(1)
      end

      it "create a new procedure to register the person" do
        expect { subject } .to change { Procedures::Registration.count } .by(1)
      end

      describe "the created procedure" do
        before { command }
        subject(:created_procedure) { Procedures::Registration.last }

        [:first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address,
         :postal_code, :email, :phone, :scope_id, :address_scope_id, :document_scope_id].each do |column|
          it "saves the #{column} column" do
            expect(created_procedure.reload.send(column)).to eq(person[column])
          end
        end
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "broadcasts :invalid" do
        expect { subject } .to broadcast(:invalid)
      end

      it "doesn't create the new procedure" do
        expect { subject } .to_not change { Procedures::Registration.count }
      end
    end

    describe "when a procedure already exists for the person" do
      let(:existing_person) { create(:person, :pending) }
      let!(:procedure) { create(:registration, person: existing_person) }

      it "does not create a new procedure" do
        expect { subject } .not_to change { Procedures::Registration.count }
      end

      describe "the updated procedure" do
        before { command }

        [:first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address,
         :postal_code, :email, :phone, :scope_id, :address_scope_id, :document_scope_id].each do |column|
          it "saves the #{column} column" do
            expect(procedure.reload.send(column)).to eq(person[column])
          end
        end
      end
    end
  end
end

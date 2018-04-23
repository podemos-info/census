# frozen_string_literal: true

require "rails_helper"

describe People::CreatePersonDataChange do
  subject(:command) { described_class.call(form: form) }

  let!(:person) { create(:person) }
  let(:form_class) { People::PersonDataChangeForm }
  let(:valid) { true }
  let(:has_changes?) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      changed_data: changed_data,
      has_changes?: has_changes?,
      scope: scope,
      address_scope: address_scope,
      document_scope: document_scope,
      **changed_data
    )
  end

  let(:changed_data) do
    {
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
      scope_id: scope&.id,
      address_scope_id: address_scope&.id,
      document_scope_id: document_scope&.id
    } .reject { |_key, value| value.nil? }
  end
  let(:first_name) { "changed" }
  let(:last_name1) { "changed too" }
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

    describe "the created procedure" do
      before { command }
      subject(:created_procedure) { Procedures::PersonDataChange.last }

      it "saves the first_name column" do
        expect(created_procedure.first_name).to eq("changed")
      end

      it "saves the last_name1 column" do
        expect(created_procedure.last_name1).to eq("changed too")
      end
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

  describe "when has no changes" do
    let(:has_changes?) { false }

    it "broadcasts :noop" do
      expect { subject } .to broadcast(:noop)
    end

    it "doesn't create the new procedure" do
      expect { subject } .to_not change { Procedures::PersonDataChange.count }
    end
  end

  describe "when a procedure already exists for the person" do
    let!(:procedure) { create(:person_data_change, person: person, changing_columns: [:last_name1, :email]) }

    it "does not create a new procedure" do
      expect { subject } .not_to change { Procedures::PersonDataChange.count }
    end

    describe "the updated procedure" do
      before { command }

      it "updates added columns in the existing procedure with the new value" do
        expect(procedure.reload.first_name).to eq("changed")
      end

      it "updates changed columns in the existing procedure with the new value" do
        expect(procedure.reload.last_name1).to eq("changed too")
      end

      it "updates the existing procedure removing the old changed columns" do
        expect(procedure.reload.email).to be_nil
      end
    end
  end
end

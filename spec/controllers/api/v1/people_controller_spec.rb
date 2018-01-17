# frozen_string_literal: true

require "rails_helper"

describe Api::V1::PeopleController, type: :controller do
  let(:person) { build(:person) }
  let(:scope) { create(:scope) }
  let(:address_scope) { create(:scope) }
  let(:level) { "person" }

  with_versioning do
    describe "create method" do
      subject(:endpoint) { post :create, params: params }
      let(:params) do
        params = { person: person.attributes.deep_symbolize_keys }
        params[:person][:scope_code] = scope.code
        params[:person][:address_scope_code] = address_scope.code
        params[:person][:document_scope_code] = person.document_scope.code
        params
      end

      it "is valid" do
        is_expected.to have_http_status(:created)
        expect(subject.content_type).to eq("application/json")
      end

      it "creates a new person" do
        expect { subject } .to change { Person.count }.by(1)
      end

      describe "person created" do
        subject(:created_person) { Person.last }
        before { endpoint }

        it "correctly sets the user scope" do
          expect(created_person.scope).to eq(scope)
        end

        it "correctly sets the user address_scope" do
          expect(created_person.address_scope).to eq(address_scope)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Api::V1::PeopleController, type: :controller do
  let(:scope) { create(:scope) }
  let(:address_scope) { create(:scope) }
  let(:document_scope) { create(:scope) }
  let(:scope_code) { scope.code }
  let(:address_scope_code) { address_scope.code }
  let(:document_scope_code) { document_scope.code }

  with_versioning do
    describe "create method" do
      subject(:endpoint) { post :create, params: params }

      let(:person) { build(:person) }
      let(:params) do
        params = { person: person.attributes.deep_symbolize_keys }
        params[:person][:scope_code] = scope_code
        params[:person][:address_scope_code] = address_scope_code
        params[:person][:document_scope_code] = document_scope_code
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

        it "correctly sets the user document_scope" do
          expect(created_person.document_scope).to eq(document_scope)
        end
      end

      context "with an invalid scope id" do
        let(:scope_code) { "AN INVALID SCOPE CODE" }

        it "is not valid" do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(subject.content_type).to eq("application/json")
        end
      end
    end

    describe "update method" do
      subject(:endpoint) { patch :update, params: { id: person.id, **params } }

      let(:person) { create(:person) }
      let(:params) do
        params = { person: person.attributes.deep_symbolize_keys }
        params[:person][:first_name] = "CHANGED"
        params[:person][:scope_code] = scope_code
        params[:person][:address_scope_code] = address_scope_code
        params[:person][:document_scope_code] = document_scope_code
        params
      end

      it "is valid" do
        is_expected.to have_http_status(:accepted)
        expect(subject.content_type).to eq("application/json")
      end

      it "updates the person" do
        expect { subject } .to change { Person.last.first_name }.from(person.first_name).to("CHANGED")
      end

      describe "person scope changed" do
        let(:scope) { create(:scope) }

        it "correctly sets the user scope" do
          expect { subject } .to change { Person.last.scope } .from(person.scope).to(scope)
        end
      end

      context "with an invalid scope id" do
        let(:scope_code) { "AN INVALID SCOPE CODE" }

        it "is not valid" do
          expect(subject).to have_http_status(:unprocessable_entity)
          expect(subject.content_type).to eq("application/json")
        end
      end
    end
  end

  describe "retrieve person information" do
    subject(:endpoint) { get :show, params: { id: person.id } }

    let(:person) { create(:person) }

    it { is_expected.to be_success }

    context "returned data" do
      subject(:response) { JSON.parse(endpoint.body) }

      it "includes person first name" do
        expect(subject["first_name"]).to eq(person.first_name)
      end

      it "includes person scope code" do
        expect(subject["scope_code"]).to eq(person.scope.code)
      end

      it "includes person document scope code" do
        expect(subject["address_scope_code"]).to eq(person.address_scope.code)
      end

      it "includes person document scope code" do
        expect(subject["document_scope_code"]).to eq(person.document_scope.code)
      end

      it "does not include hidden fields" do
        expect(subject.keys).not_to include(%w(created_at updated_at deleted_at flags verifications scope_id address_scope_id document_scope_id))
      end
    end
  end
end

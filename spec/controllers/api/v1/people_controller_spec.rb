# frozen_string_literal: true

require "rails_helper"

describe Api::V1::PeopleController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip("Add a hash of attributes valid for your model")
  end

  let(:invalid_attributes) do
    skip("Add a hash of attributes invalid for your model")
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PeopleController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      person = Person.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      person = Person.create! valid_attributes
      get :show, params: { id: person.to_param }, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Person" do
        expect do
          post :create, params: { person: valid_attributes }, session: valid_session
        end.to change(Person, :count).by(1)
      end

      it "renders a JSON response with the new person" do
        post :create, params: { person: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json")
        expect(response.location).to eq(person_url(Person.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new person" do
        post :create, params: { person: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        skip("Add a hash of attributes valid for your model")
      end

      it "updates the requested person" do
        person = Person.create! valid_attributes
        put :update, params: { id: person.to_param, person: new_attributes }, session: valid_session
        person.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the person" do
        person = Person.create! valid_attributes

        put :update, params: { id: person.to_param, person: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the person" do
        person = Person.create! valid_attributes

        put :update, params: { id: person.to_param, person: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end
end

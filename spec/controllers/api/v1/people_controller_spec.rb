# frozen_string_literal: true

require "rails_helper"

describe Api::V1::PeopleController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let!(:person) { create(:person) }

  context "index method" do
    subject { get :index }
    it "returns a success response" do
      expect(subject).to be_success
    end
  end

  context "show method" do
    subject { get :index, params: { id: person.id } }
    it "returns a success response" do
      expect(subject).to be_success
    end
  end

  context "create method" do
    let(:person) { build(:person) }
    subject { post :create, params: { person: person.attributes } }
    it { expect { subject } .to change { Person.count }.by(1) }
    it { expect(subject).to have_http_status(:created) }
    it { expect(subject.content_type).to eq("application/json") }
    it { expect(subject.location).to eq(person_url(Person.last)) }
  end

  context "update method" do
    subject do
      person.assign_attributes first_name: "KKKKKK"
      patch :update, params: { id: person.id, person: person.attributes }
    end
    it { expect(subject).to have_http_status(:ok) }
    it { expect(subject.content_type).to eq("application/json") }
    it { expect { subject } .to change { person.first_name }.to("KKKKKK") }
  end
end

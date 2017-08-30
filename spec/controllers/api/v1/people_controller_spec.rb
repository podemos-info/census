# frozen_string_literal: true

require "rails_helper"

describe Api::V1::PeopleController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:person) { build(:person) }
  let(:level) { "person" }

  context "create method" do
    let(:attachment) { build(:attachment) }
    let(:params) do
      params = { person: person.attributes.deep_symbolize_keys }
      params[:person][:level] = level
      params[:person][:scope_code] = person.scope.code
      params[:person][:address_scope_code] = person.address_scope.code
      params[:person][:document_scope_code] = person.document_scope.code
      params[:person][:files] = [api_attachment_format(attachment), api_attachment_format(attachment)]
      params
    end

    subject do
      post :create, params: params
    end

    it "is valid" do
      expect(subject).to have_http_status(:created)
      expect(subject.content_type).to eq("application/json")
    end

    it "creates a new person" do
      expect { subject } .to change { Person.count }.by(1)
    end

    it "creates a new verification procedure" do
      expect { subject } .to change { Procedure.count }.by(1)
    end

    it "correctly sets the user scope" do
      subject
      expect(Person.last.scope).to eq(person.scope)
    end

    it "correctly sets the user address_scope" do
      subject
      expect(Person.last.address_scope).to eq(person.address_scope)
    end

    context "when changing level" do
      let(:level) { "member" }

      it "creates a new verification and a new change membership procedure" do
        expect { subject } .to change { Procedure.count }.by(2)
      end
    end
  end

  context "change_membership_level method" do
    let(:person) { create(:person) }
    let(:level) { "member" }

    subject do
      patch :change_membership_level, params: { id: person.participa_id, level: level }
    end

    it "is valid" do
      expect(subject).to have_http_status(:accepted)
      expect(subject.content_type).to eq("application/json")
    end

    it "creates a new change membership procedure" do
      expect { subject } .to change { Procedure.count }.by(1)
    end

    context "with same level than current" do
      let(:level) { person.level }

      it "is not valid" do
        expect(subject).to have_http_status(:unprocessable_entity)
        expect(subject.content_type).to eq("application/json")
      end

      it "doesn't create a new change membership procedure" do
        expect { subject } .to change { Procedure.count }.by(0)
      end
    end
  end
end

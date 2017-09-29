# frozen_string_literal: true

require "rails_helper"

describe PeopleController, type: :controller do
  render_views
  include_context "devise login"

  let(:resource_class) { Person }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let!(:person) { create(:person) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :new, :create, :edit, :update)
  end

  it "handles people" do
    expect(resource.resource_name).to eq("Person")
  end

  it "shows menu" do
    expect(resource).to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("index") }
  end

  context "new page" do
    subject { get :new }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("new") }
  end

  context "create page" do
    let(:person) { build(:person) }
    subject { put :create, params: { person: person.attributes } }
    it { expect { subject } .to change { Person.count }.by(1) }
    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(person_url(Person.last)) }
  end

  context "edit page" do
    subject { get :edit, params: { id: person.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  with_versioning do
    context "show page" do
      subject { get :show, params: { id: person.id } }
      it { expect(subject).to be_success }
      it { expect(subject).to render_template("show") }
    end

    context "update page" do
      subject do
        person.assign_attributes first_name: "KKKKKK"
        patch :update, params: { id: person.id, person: person.attributes }
      end
      it { expect(subject).to have_http_status(:found) }
      it { expect(subject.location).to eq(person_url(person.id)) }
      it { expect { subject } .to change { person.first_name }.to("KKKKKK") }
    end
  end
end

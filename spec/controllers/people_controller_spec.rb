# frozen_string_literal: true

require "rails_helper"

describe PeopleController, type: :controller do
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

  context "show page" do
    subject { get :show, params: { id: person.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("show") }
  end

  context "new page" do
    subject { get :new }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("new") }
  end

  context "create page" do
    subject do
      person.assign_attributes first_name: "KKKKKK"
      put :create, params: { person: person.attributes }
    end
    it do
      subject.code == "302" && person = Person.last
      expect(subject).to redirect_to(person_path(person.id))
    end

    it "should have changed the person" do
      subject.code == "302" && person = Person.last
      expect(person.first_name).to eq("KKKKKK")
    end
  end

  context "edit page" do
    subject { get :edit, params: { id: person.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  context "update page" do
    subject do
      person.assign_attributes first_name: "KKKKKK"
      patch :update, params: { id: person.id, person: person.attributes }
    end
    it { expect(subject).to redirect_to(person_path(person.id)) }

    it "should have changed the person" do
      subject.code == "302" && person.reload
      expect(person.first_name).to eq("KKKKKK")
    end
  end
end

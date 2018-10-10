# frozen_string_literal: true

require "rails_helper"

describe PayeesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Payee }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:payee) { create(:payee) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :new, :create, :edit, :update, :destroy)
  end

  it "handles payees" do
    expect(resource.resource_name).to eq("Payee")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"
  end

  describe "show page" do
    subject { get :show, params: { id: payee.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }

    include_examples "tracks the user visit"
  end

  describe "new page" do
    subject { get :new }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("new") }

    include_examples "tracks the user visit"
  end

  describe "create page" do
    subject { put :create, params: { payee: payee.attributes } }

    let(:payee) { build(:payee) }

    it { expect { subject } .to change(Payee, :count).by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(payee_url(Payee.last)) }

    include_examples "tracks the user visit"
  end

  describe "edit page" do
    subject { get :edit, params: { id: payee.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("edit") }

    include_examples "tracks the user visit"
  end

  describe "update page" do
    subject do
      payee.assign_attributes name: "KKKKKK"
      patch :update, params: { id: payee.id, payee: payee.attributes }
    end

    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(payee_url(payee.id)) }
    it { expect { subject } .to change(payee, :name).to("KKKKKK") }

    include_examples "tracks the user visit"
  end

  describe "destroy page" do
    subject { put :destroy, params: { id: payee.id } }

    it { expect { subject } .to change(Payee, :count).by(-1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(payees_url) }

    include_examples "tracks the user visit"
  end
end

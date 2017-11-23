# frozen_string_literal: true

require "rails_helper"

describe BicsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { Bic }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:bic) { create(:bic) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :new, :create, :edit, :update, :destroy)
  end

  it "handles bics" do
    expect(resource.resource_name).to eq("Bic")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "show page" do
    subject { get :show, params: { id: bic.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  describe "new page" do
    subject { get :new }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  describe "create page" do
    let(:bic) { build(:bic) }
    subject { put :create, params: { bic: bic.attributes } }
    it { expect { subject } .to change { Bic.count }.by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(bic_url(Bic.last)) }
  end

  describe "edit page" do
    subject { get :edit, params: { id: bic.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("edit") }
  end

  describe "update page" do
    subject do
      bic.assign_attributes bank_code: "KKKKKK"
      patch :update, params: { id: bic.id, bic: bic.attributes }
    end
    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(bic_url(bic.id)) }
    it { expect { subject } .to change { bic.bank_code }.to("KKKKKK") }
  end

  describe "destroy page" do
    subject { put :destroy, params: { id: bic.id } }
    it { expect { subject } .to change { Bic.count }.by(-1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(bics_url) }
  end
end

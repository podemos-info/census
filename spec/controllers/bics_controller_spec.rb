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

  it "does not show menu" do
    is_expected.not_to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "new page" do
    subject { get :new }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  context "create page" do
    let(:bic) { build(:bic) }
    subject { put :create, params: { bic: bic.attributes } }
    it { expect { subject } .to change { Bic.count }.by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(bic_url(Bic.last)) }
  end

  context "edit page" do
    subject { get :edit, params: { id: bic.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("edit") }
  end
end

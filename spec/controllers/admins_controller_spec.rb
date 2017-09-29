# frozen_string_literal: true

require "rails_helper"

describe AdminsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { Admin }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:admin) { create(:admin) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles admins" do
    expect(subject.resource_name).to eq("Admin")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  with_versioning do
    context "show page" do
      subject { get :show, params: { id: admin.id } }
      it { is_expected.to be_success }
      it { is_expected.to render_template("show") }
    end
  end
end

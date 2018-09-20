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
    expect(subject.defined_actions).to contain_exactly(:index, :show, :edit, :update)
  end

  it "handles admins" do
    expect(subject.resource_name).to eq("Admin")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }
  end

  describe "edit page" do
    subject { get :edit, params: { id: admin.id } }

    it { expect(subject).to be_successful }
    it { expect(subject).to render_template("edit") }
  end

  with_versioning do
    describe "show page" do
      subject { get :show, params: { id: admin.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }
    end

    describe "update page" do
      subject do
        admin.assign_attributes role: "data"
        patch :update, params: { id: admin.id, admin: admin.attributes }
      end

      it { expect(subject).to have_http_status(:found) }
      it { expect(subject.location).to eq(admin_url(admin.id)) }
      it { expect { subject } .to change(admin, :role).to("data") }
    end
  end
end

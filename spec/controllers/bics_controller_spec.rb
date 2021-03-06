# frozen_string_literal: true

require "rails_helper"

describe BicsController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Bic }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:bic) { create(:bic) }
  let(:current_admin) { create(:admin, :finances) }

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

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"
  end

  describe "show page" do
    subject { get :show, params: { id: bic.id } }

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
    subject { put :create, params: { bic: bic.attributes } }

    let(:bic) { build(:bic) }

    it { expect { subject } .to change(Bic, :count).by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(bic_url(Bic.last.id)) }

    include_examples "tracks the user visit"

    it_behaves_like "an admin page that forbids modifications on slave mode"

    context "with invalid params" do
      let(:bic) { build(:bic, :invalid) }

      it { expect { subject } .not_to change(Bic, :count) }
      it { is_expected.to be_successful }
      it { is_expected.to render_template("new") }
    end

    context "when saving fails" do
      before { stub_command("Payments::SaveBic", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("new") }

      it "shows an error message" do
        expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al guardar el registro.")
      end
    end
  end

  describe "edit page" do
    subject { get :edit, params: { id: bic.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("edit") }
  end

  describe "update page" do
    subject { patch :update, params: { id: bic.id, bic: bic.attributes } }

    before { bic.assign_attributes bic: new_bic }

    let(:new_bic) { "ABCD#{bic.country}XX" }

    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(bic_url(bic.id)) }
    it { expect { subject } .to change { Bic.find(bic.id).bic }.to(new_bic) }

    include_examples "tracks the user visit"

    it_behaves_like "an admin page that forbids modifications on slave mode"

    context "with invalid params" do
      before { bic.assign_attributes bic: "1a22" }

      it { expect { subject } .not_to change(Bic, :count) }
      it { is_expected.to be_successful }
      it { is_expected.to render_template("edit") }
    end

    context "when saving fails" do
      before { stub_command("Payments::SaveBic", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("edit") }

      it "shows an error message" do
        expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al guardar el registro.")
      end
    end
  end

  describe "destroy page" do
    subject { put :destroy, params: { id: bic.id } }

    it { expect { subject } .to change(Bic, :count).by(-1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(bics_url) }

    include_examples "tracks the user visit"

    it_behaves_like "an admin page that forbids modifications on slave mode"
  end
end

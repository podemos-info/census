# frozen_string_literal: true

require "rails_helper"

describe VersionsController, type: :controller do
  render_views
  include_context "devise login"

  with_versioning do
    subject(:resource) { all_resources[resource_class] }

    let(:resource_class) { Version }
    let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
    let!(:order_version) { create(:version, :order) }
    let!(:person_version) { create(:version) }
    let!(:procedure_version) { create(:version, :procedure) }

    it "defines actions" do
      expect(subject.defined_actions).to contain_exactly(:index, :show)
    end

    it "handles visits" do
      expect(subject.resource_name).to eq("Version")
    end

    it "shows menu" do
      is_expected.to be_include_in_menu
    end

    describe "index page" do
      subject { get :index }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "doesn't track the user visit"
    end

    describe "show page" do
      subject { get :show, params: { id: version.id } }

      let(:version) { person_version }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "doesn't track the user visit"

      context "when showing an order version" do
        let(:version) { order_version }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
      end

      context "when showing a procedure version" do
        let(:version) { procedure_version }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
      end
    end
  end
end

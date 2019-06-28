# frozen_string_literal: true

require "rails_helper"

describe PersonLocationsController, type: :controller do
  render_views
  include_context "with a devise login"

  with_versioning do
    subject(:resource) { all_resources[resource_class] }

    let(:resource_class) { PersonLocation }
    let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
    let!(:person_location) { create(:person_location) }

    it "defines actions" do
      expect(subject.defined_actions).to contain_exactly(:index, :show)
    end

    it "handles person locations" do
      expect(subject.resource_name).to eq("PersonLocation")
    end

    it "shows menu" do
      is_expected.not_to be_include_in_menu
    end

    describe "index page" do
      subject { get :index, params: { person_id: person_location.person_id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "tracks the user visit"
    end

    describe "show page" do
      subject do
        get :show, params: { person_id: person_location.person_id,
                             id: person_location.id }
      end

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "tracks the user visit"
    end
  end
end

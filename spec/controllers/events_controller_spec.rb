# frozen_string_literal: true

require "rails_helper"

describe EventsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Event }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:event) { create(:event) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles events" do
    expect(subject.resource_name).to eq("Event")
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
    subject { get :show, params: { id: event.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }

    include_examples "doesn't track the user visit"
  end
end

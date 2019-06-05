# frozen_string_literal: true

require "rails_helper"

describe CampaignsController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Campaign }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:campaign) { create(:campaign) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :edit, :update, :destroy)
  end

  it "handles bics" do
    expect(resource.resource_name).to eq("Campaign")
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
    subject { get :show, params: { id: campaign.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }

    include_examples "tracks the user visit"
  end

  describe "edit page" do
    subject { get :edit, params: { id: campaign.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("edit") }

    include_examples "tracks the user visit"
  end

  describe "update page" do
    subject do
      campaign.assign_attributes campaign_code: "KKKKKK"
      patch :update, params: { id: campaign.id, bic: campaign.attributes }
    end

    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(campaign_url(campaign.id)) }
    it { expect { subject } .to change(campaign, :campaign_code).to("KKKKKK") }

    include_examples "tracks the user visit"
  end

  describe "destroy page" do
    subject { put :destroy, params: { id: campaign.id } }

    it { expect { subject } .to change(Campaign, :count).by(-1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(campaigns_url) }

    include_examples "tracks the user visit"
  end
end

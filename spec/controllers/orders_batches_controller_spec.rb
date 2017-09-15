# frozen_string_literal: true

require "rails_helper"

describe OrdersBatchesController, type: :controller do
  render_views

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { OrdersBatch }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:orders_batch) { create(:orders_batch) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles orders" do
    expect(subject.resource_name).to eq("OrdersBatch")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  context "index page" do
    subject(:page) { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "show page" do
    subject(:page) { get :show, params: { id: orders_batch.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end
end

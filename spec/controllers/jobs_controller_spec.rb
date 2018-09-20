# frozen_string_literal: true

require "rails_helper"

describe JobsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Job }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:job) { create(:job, :finished) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles events" do
    expect(subject.resource_name).to eq("Job")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }
  end

  describe "show page" do
    subject { get :show, params: { id: job.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }
  end

  describe "running processes count" do
    subject { post :running }

    it { is_expected.to be_successful }
    it { expect(subject.content_type).to eq("application/json") }
    it { expect(subject.body).to eq("0") }

    context "when there are running jobs" do
      before { job }

      let(:job) { create(:job, :running, user: current_admin) }

      it { is_expected.to be_successful }
      it { expect(subject.content_type).to eq("application/json") }
      it { expect(subject.body).to eq("1") }
    end
  end
end

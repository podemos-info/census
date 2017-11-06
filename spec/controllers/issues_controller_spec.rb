# frozen_string_literal: true

require "rails_helper"

describe IssuesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { Issue }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:issue) { issue_unread.issue }
  let(:issue_unread) { create(:issue_unread) }
  let(:current_admin) { issue_unread.admin }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles events" do
    expect(subject.resource_name).to eq("Issue")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  describe "show page" do
    subject { get :show, params: { id: issue.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  describe "assign me an issue" do
    subject { patch :assign_me, params: { id: issue.id } }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(issues_url) }
    it "assigns the issue to the current admin" do
      expect { subject } .to change { Issue.find(issue.id).assigned_to } .from(nil).to(current_admin.person)
    end
  end

  describe "mark issue as fixed" do
    subject { patch :mark_as_fixed, params: { id: issue.id } }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(issues_url) }
    it "sets the issues fixed_at moment" do
      expect { subject } .to change { Issue.find(issue.id).fixed_at } .from(nil)
    end
  end
end

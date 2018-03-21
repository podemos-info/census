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
    expect(subject.defined_actions).to contain_exactly(:index, :show, :edit, :update)
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

  context "edit page" do
    subject { get :edit, params: { id: issue.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  with_versioning do
    describe "fix an issue" do
      subject { patch :update, params: { id: issue.id, issue: { chosen_person_id: issue.procedure.person_id, comment: "Is real" } } }

      let!(:issue) { create(:duplicated_document) }

      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(issue_url(issue)) }
      it "closes the issue" do
        expect { subject } .not_to change { issue.reload.closed? } .from(false)
      end
    end
  end
end

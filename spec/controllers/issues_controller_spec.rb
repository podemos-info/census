# frozen_string_literal: true

require "rails_helper"

describe IssuesController, type: :controller do
  render_views
  include_context "with a devise login"

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
    subject { get :index, params: params }

    let(:params) { {} }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"

    context "when ordered by issue type" do
      let(:params) { { order: "issue_type_desc" } }

      it { is_expected.to be_successful }
    end
  end

  describe "show page" do
    subject { get :show, params: { id: issue.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }

    include_examples "tracks the user visit"
  end

  describe "assign me an issue" do
    subject { patch :assign_me, params: { id: issue.id } }

    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(issues_url) }

    it "assigns the issue to the current admin" do
      expect { subject } .to change { Issue.find(issue.id).assigned_to } .from(nil).to(current_admin.person)
    end

    include_examples "tracks the user visit"
  end

  describe "edit page" do
    subject { get :edit, params: { id: issue.id } }

    it { expect(subject).to be_successful }
    it { expect(subject).to render_template("edit") }

    include_examples "tracks the user visit"
  end

  with_versioning do
    {
      admin_remark: {
        role: :data,
        request_params: ->(_issue) { { fixed: true, comment: "Person data fixed" } }
      },
      duplicated_document: {
        role: :data,
        request_params: ->(issue) { { chosen_person_id: issue.procedure.person_id, cause: :mistake, comment: "Is real" } }
      },
      duplicated_person: {
        role: :data,
        request_params: ->(issue) { { chosen_person_ids: [issue.procedure.person_id], cause: :mistake, comment: "Is real" } }
      },
      untrusted_email: {
        role: :data,
        request_params: ->(_issue) { { trusted: true, comment: "Is real" } }
      },
      untrusted_phone: {
        role: :data,
        request_params: ->(_issue) { { trusted: false, comment: "Is not real" } }
      },
      duplicated_verified_phone: {
        role: :data,
        request_params: ->(issue) { { chosen_person_ids: [issue.procedure.person_id], comment: "Phone reassignment" } }
      },
      missing_bic: {
        role: :finances,
        request_params: ->(issue) { { bic: "ABCD#{issue.payment_methods.first.iban_parts[:country]}XX" } }
      }
    }.each do |issue_type, params|
      describe "fix a #{issue_type.to_s.humanize} issue" do
        subject { patch :update, params: { id: issue.id, issue: params[:request_params].call(issue) } }

        let(:issue) { create(issue_type) }
        let(:current_admin) { create(:admin, params[:role]) }

        it { is_expected.to have_http_status(:found) }
        it { expect(subject.location).to eq(issue_url(issue)) }

        it "closes the issue" do
          expect { subject } .to change { issue.reload.closed? } .from(false).to(true)
        end
      end
    end

    context "when fixing an issue returns an error" do
      subject { patch :update, params: { id: issue.id, issue: { chosen_person_id: issue.procedure.person_id, cause: :mistake, comment: "Is real" } } }

      before { stub_command("Issues::FixIssue", :error) }

      let(:issue) { create(:duplicated_document) }

      it { is_expected.to have_http_status(:ok) }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al intentar resolver la incidencia") }

      it "closes the issue" do
        expect { subject } .not_to change { issue.reload.closed? } .from(false)
      end

      include_examples "tracks the user visit"
    end
  end
end

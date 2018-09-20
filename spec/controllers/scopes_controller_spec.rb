# frozen_string_literal: true

require "rails_helper"

describe ScopesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Scope }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:scope) { create(:scope) }

  it "defines actions" do
    expect(subject.defined_actions).to be_empty
  end

  it "handles people" do
    expect(subject.resource_name).to eq("Scope")
  end

  it "does not show menu" do
    is_expected.not_to be_include_in_menu
  end

  describe "browse page" do
    subject(:page) { get :browse, params: params }

    let(:params) { { title: "field" } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("browse") }

    context "with a current scope" do
      let(:params) { { title: "field", current: scope.id } }
      let(:scope) { create(:scope) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("browse") }
    end

    context "with a root scope" do
      let(:params) { { title: "field", root: scope.id } }
      let(:scope) { create(:scope) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("browse") }
    end

    context "with a root scope and a current scope" do
      let(:params) { { title: "field", root: root_scope.id, current: scope.id } }
      let(:root_scope) { create(:scope) }
      let(:scope) { create(:scope) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("browse") }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe DownloadsController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Download }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:person) { create(:person) }
  let!(:download) { create(:download, person: person) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles downloads" do
    expect(subject.resource_name).to eq("Download")
  end

  it "does not show menu" do
    is_expected.not_to be_include_in_menu
  end

  describe "index page" do
    subject { get :index, params: { person_id: person.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"
  end

  describe "show page" do
    subject { get :show, params: { person_id: person.id, id: download.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("show") }

    include_examples "tracks the user visit"
  end

  describe "download file" do
    subject { get :download, params: { person_id: person.id, id: download.id } }

    it { expect(subject).to be_successful }
    it { expect(subject.content_type).to eq("application/pdf") }
    it { expect(subject.body).to eq(download.file.read) }

    include_examples "tracks the user visit"
  end
end

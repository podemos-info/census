# frozen_string_literal: true

require "rails_helper"

describe DownloadsController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Download }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:person) { current_admin.person }
  let(:download) { create(:download, person: person) }
  let(:other_download) { create(:download) }

  before { person && download && other_download }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show, :destroy)
  end

  it "handles downloads" do
    expect(subject.resource_name).to eq("Download")
  end

  it "show menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }
    it { expect(subject.body).not_to include(download_path(other_download)) }

    include_examples "tracks the user visit"

    context "when browsing by person" do
      subject { get :index, params: { person_id: person.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }
      it { expect(subject.body).not_to include(download_path(other_download)) }

      include_examples "tracks the user visit"
    end

    context "when browsing by orders batch" do
      subject { get :index, params: { orders_batch_id: orders_batch.id } }

      let(:download) { create(:download, person: person, orders_batches: [orders_batch]) }
      let(:orders_batch) { create(:orders_batch) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }
      it { expect(subject.body).not_to include(download_path(other_download)) }

      include_examples "tracks the user visit"
    end

    context "when user is data admin" do
      let(:current_admin) { create(:admin, :data) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }
      it { expect(subject.body).to include(download_path(other_download)) }
    end
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

  describe "destroy page" do
    subject { put :destroy, params: { id: download.id } }

    it { expect { subject } .to change { Download.kept.count } .by(-1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(downloads_url) }

    include_examples "tracks the user visit"
  end

  describe "recover page" do
    subject { patch :recover, params: { id: download.id } }

    let(:download) { create(:download, :discarded, person: person) }

    it { expect { subject } .to change { Download.kept.count } .by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(downloads_url) }

    include_examples "tracks the user visit"
  end
end

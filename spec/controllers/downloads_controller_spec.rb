# frozen_string_literal: true

require "rails_helper"

describe DownloadsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { Download }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:download) { create(:download) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
  end

  it "handles downloads" do
    expect(subject.resource_name).to eq("Download")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "show page" do
    subject { get :show, params: { id: download.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  context "download file" do
    subject { get :download, params: { id: download.id } }
    it { expect(subject).to be_success }
    it { expect(subject.content_type).to eq("application/pdf") }
    it { expect(subject.body).to eq(download.file.read) }
  end
end

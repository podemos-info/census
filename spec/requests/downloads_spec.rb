# frozen_string_literal: true

require "rails_helper"

describe "Downloads", type: :request do
  include_context "devise login"

  subject(:page) { get downloads_path }
  let!(:download) { create(:download) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get download_path(id: download.id) }
    it { is_expected.to eq(200) }
  end
end

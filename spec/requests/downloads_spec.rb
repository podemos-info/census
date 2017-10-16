# frozen_string_literal: true

require "rails_helper"

describe "Downloads", type: :request do
  include_context "devise login"

  subject(:page) { get person_downloads_path(person_id: person.id) }
  let!(:person) { create(:person) }
  let!(:download) { create(:download, person: person) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get person_download_path(person_id: person.id, id: download.id) }
    it { is_expected.to eq(200) }
  end
end

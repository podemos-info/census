# frozen_string_literal: true

require "rails_helper"

describe "Versions", type: :request do
  include_context "devise login"

  with_versioning do
    subject(:page) { get versions_path }
    let!(:version) { create(:version) }

    context "index page" do
      it { is_expected.to eq(200) }
    end

    context "show page" do
      subject(:page) { get version_path(id: version.id) }
      it { is_expected.to eq(200) }
    end
  end
end

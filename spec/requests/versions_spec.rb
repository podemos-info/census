# frozen_string_literal: true

require "rails_helper"

describe "Versions", type: :request do
  include_context "with a devise login"

  with_versioning do
    subject(:page) { get versions_path }

    let!(:version) { create(:version) }

    describe "index page" do
      it { is_expected.to eq(200) }
    end

    describe "show page" do
      subject(:page) { get version_path(id: version.id) }

      it { is_expected.to eq(200) }
    end
  end
end

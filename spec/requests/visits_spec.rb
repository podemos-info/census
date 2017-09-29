# frozen_string_literal: true

require "rails_helper"

describe "Visits", type: :request do
  include_context "devise login"

  subject(:page) { get visits_path }
  let!(:visit) { create(:visit) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get visit_path(id: visit.id) }
    it { is_expected.to eq(200) }
  end
end

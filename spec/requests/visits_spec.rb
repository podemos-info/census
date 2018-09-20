# frozen_string_literal: true

require "rails_helper"

describe "Visits", type: :request do
  include_context "devise login"

  subject(:page) { get visits_path }

  let(:visit) { create(:visit) }

  describe "index page" do
    it { is_expected.to eq(200) }
  end

  describe "show page" do
    subject(:page) { get visit_path(id: visit.id) }

    it { is_expected.to eq(200) }
  end

  describe "visit events page" do
    subject { get visit_events_path(visit_id: visit.id) }

    before { event }

    let(:event) { create(:event, visit: visit) }

    it { expect(subject).to eq(200) }
  end
end

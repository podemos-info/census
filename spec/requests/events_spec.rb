# frozen_string_literal: true

require "rails_helper"

describe "Events", type: :request do
  include_context "with a devise login"

  before do
    event
    post csp_report_path(info: { test_info: [1, 2, 3] })
    get people_path(q: { first_name_eq: "Test" })
    get person_path(id: create(:person).id)
  end

  let(:event) { create(:event) }

  describe "index page" do
    subject(:page) { get events_path }

    it { is_expected.to eq(200) }
  end

  describe "show page" do
    subject(:page) { get event_path(id: event.id) }

    it { is_expected.to eq(200) }
  end
end

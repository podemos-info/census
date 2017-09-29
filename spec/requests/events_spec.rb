# frozen_string_literal: true

require "rails_helper"

describe "Events", type: :request do
  include_context "devise login"

  subject(:page) { get events_path }
  let!(:event) { create(:event) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get event_path(id: event.id) }
    it { is_expected.to eq(200) }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe "Dashboard", type: :request do
  context "index page" do
    before { get root_path }
    it { expect(response).to have_http_status(200) }
  end
end

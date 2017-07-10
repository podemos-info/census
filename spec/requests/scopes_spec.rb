# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Scopes", type: :request do
  describe "GET /scopes" do
    it "works! (now write some real specs)" do
      get scopes_path
      expect(response).to have_http_status(200)
    end
  end
end

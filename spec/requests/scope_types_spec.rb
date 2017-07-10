# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ScopeTypes", type: :request do
  describe "GET /scope_types" do
    it "works! (now write some real specs)" do
      get scope_types_path
      expect(response).to have_http_status(200)
    end
  end
end

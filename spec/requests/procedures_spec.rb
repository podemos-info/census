# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Procedures", type: :request do
  describe "GET /procedures" do
    it "works! (now write some real specs)" do
      get procedures_path
      expect(response).to have_http_status(200)
    end
  end
end

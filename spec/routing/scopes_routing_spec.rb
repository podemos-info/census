# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScopesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/scopes").to route_to("scopes#index")
    end

    it "routes to #show" do
      expect(get: "/scopes/1").to route_to("scopes#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/scopes").to route_to("scopes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/scopes/1").to route_to("scopes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/scopes/1").to route_to("scopes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/scopes/1").to route_to("scopes#destroy", id: "1")
    end
  end
end

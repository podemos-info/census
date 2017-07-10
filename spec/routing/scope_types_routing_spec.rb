# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScopeTypesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/scope_types").to route_to("scope_types#index")
    end

    it "routes to #show" do
      expect(get: "/scope_types/1").to route_to("scope_types#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/scope_types").to route_to("scope_types#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/scope_types/1").to route_to("scope_types#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/scope_types/1").to route_to("scope_types#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/scope_types/1").to route_to("scope_types#destroy", id: "1")
    end
  end
end

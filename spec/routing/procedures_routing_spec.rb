# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProceduresController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/procedures").to route_to("procedures#index")
    end

    it "routes to #show" do
      expect(get: "/procedures/1").to route_to("procedures#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/procedures").to route_to("procedures#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/procedures/1").to route_to("procedures#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/procedures/1").to route_to("procedures#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/procedures/1").to route_to("procedures#destroy", id: "1")
    end
  end
end

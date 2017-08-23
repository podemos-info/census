# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PeopleController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/v1/people").to route_to("api/v1/people#create")
    end

    it "routes to #change_membership_level via PATCH" do
      expect(patch: "/api/v1/people/1/change_membership_level").to route_to("api/v1/people#change_membership_level", id: "1")
    end
  end
end

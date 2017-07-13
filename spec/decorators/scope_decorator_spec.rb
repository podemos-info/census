# frozen_string_literal: true

require "rails_helper"

describe ScopeDecorator do
  let(:scope) { build(:scope) }
  subject { scope.decorate }

  context "paths" do
    let!(:grandparent) { create(:scope, name: Census::Faker::Localized.literal("grandparent")) }
    let!(:parent) { create(:scope, name: Census::Faker::Localized.literal("parent"), parent: grandparent) }
    let!(:scope) { create(:scope, name: Census::Faker::Localized.literal("scope"), parent: parent) }

    it "returns the scope path" do
      expect(subject.show_path).to eq("scope, parent, grandparent")
    end

    it "returns the scope path with root" do
      expect(subject.show_path(grandparent)).to eq("scope, parent")
    end
  end
end

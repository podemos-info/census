# frozen_string_literal: true

require "rails_helper"

describe ScopeDecorator do
  subject(:decorator) { scope.decorate(context: { current_admin: admin }) }
  let(:scope) { build(:scope) }
  let(:admin) { build(:admin) }

  describe "#full_path" do
    subject(:full_path) { decorator.full_path(*args) }
    let!(:grandparent) { create(:scope, name: Census::Faker::Localized.literal("grandparent")) }
    let!(:parent) { create(:scope, name: Census::Faker::Localized.literal("parent"), parent: grandparent) }
    let!(:scope) { create(:scope, name: Census::Faker::Localized.literal("scope"), parent: parent) }

    context "when has no root path" do
      let(:args) { [] }

      it "returns the full scope path" do
        is_expected.to eq("scope, parent, grandparent")
      end
    end

    context "when has a root path" do
      let(:args) { [parent] }

      it "returns only until the root path" do
        is_expected.to eq("scope, parent")
      end
    end

    context "when it is the root path" do
      let(:args) { [scope] }

      it "returns only the scope name" do
        is_expected.to eq("scope")
      end
    end
  end
end

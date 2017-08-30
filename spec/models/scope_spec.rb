# frozen_string_literal: true

require "rails_helper"

describe Scope, :db do
  let(:scope) { build(:scope) }

  subject { scope }

  matcher :match_scopes do |expected|
    match do |results|
      RSpec::Matchers::BuiltIn::ContainExactly.new(results.map(&:code)).matches?(expected.map(&:code))
    end
  end

  matcher :eq_scopes do |expected|
    match do |results|
      expected.zip(results).all? { |exp, res| exp&.code == res&.code }
    end
  end

  it { is_expected.to be_valid }

  context "local scope" do
    let!(:scope) { create(:local_scope) }

    it "#local returns configured scope" do
      expect(Scope.local).to eq scope
    end
  end

  context "hierarchies" do
    let(:scope) { create(:scope) }
    let(:child_scope) { create(:scope, parent: scope) }
    let!(:grand_child_scope) { create(:scope, parent: child_scope) }
    let!(:other_scope) { create(:local_scope) }

    it "#top_level returns top level scopes" do
      expect(Scope.top_level).to match_scopes [scope, other_scope]
    end

    context "#descendants" do
      it "returns scope and its children" do
        expect(subject.descendants).to match_scopes [scope, child_scope, grand_child_scope]
      end

      it "returns only the scope when there are no children" do
        expect(other_scope.descendants).to match_scopes [other_scope]
      end

      it "does not return the ancestors" do
        expect(child_scope.descendants).to match_scopes [child_scope, grand_child_scope]
      end
    end

    context "#not_descendants" do
      it "does not include the scope or its descendants" do
        expect(scope.not_descendants).to match_scopes [other_scope]
      end

      it "includes scope ancestors" do
        expect(child_scope.not_descendants).to match_scopes [scope, other_scope]
      end
    end

    context "#part_of_scopes" do
      it "include the scope and its ancestors in descending order" do
        expect(grand_child_scope.part_of_scopes).to eq_scopes [scope, child_scope, grand_child_scope]
      end
      it "include the scope and its ancestors until the root scope" do
        expect(grand_child_scope.part_of_scopes(scope)).to eq_scopes [child_scope, grand_child_scope]
      end
    end
  end
end

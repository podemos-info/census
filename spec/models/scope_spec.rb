# frozen_string_literal: true

require "rails_helper"

describe Scope, :db do
  subject { scope }

  let(:scope) { build(:scope) }

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

  describe "#local" do
    subject { described_class.local }

    before { scope }

    let(:scope) { create(:local_scope) }

    it { is_expected.to eq scope }
  end

  context "with scope hierarchies" do
    before { grand_child_scope && other_scope }

    let(:scope) { create(:scope) }
    let(:child_scope) { create(:scope, parent: scope) }
    let(:grand_child_scope) { create(:scope, parent: child_scope) }
    let(:other_scope) { create(:local_scope) }

    describe "#top_level" do
      subject { described_class.top_level }

      it { is_expected .to match_scopes [scope, other_scope] }
    end

    describe "#descendants" do
      subject { scope.descendants }

      it { is_expected.to match_scopes [scope, child_scope, grand_child_scope] }

      context "with a child scope" do
        subject { child_scope.descendants }

        it { is_expected.to match_scopes [child_scope, grand_child_scope] }
      end

      context "with an unrelated scope" do
        subject { other_scope.descendants }

        it { is_expected.to match_scopes [other_scope] }
      end
    end

    describe "#not_descendants" do
      subject { scope.not_descendants }

      it { is_expected.to match_scopes [other_scope] }

      context "with a child scope" do
        subject { child_scope.not_descendants }

        it { is_expected.to match_scopes [scope, other_scope] }
      end
    end

    describe "#part_of_scopes" do
      subject { grand_child_scope.part_of_scopes }

      it { is_expected.to eq_scopes [scope, child_scope, grand_child_scope] }

      context "with a root scope as a parameter" do
        subject { grand_child_scope.part_of_scopes(scope) }

        it { is_expected.to eq_scopes [child_scope, grand_child_scope] }
      end
    end
  end
end

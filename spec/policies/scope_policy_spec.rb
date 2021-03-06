# frozen_string_literal: true

require "rails_helper"

describe ScopePolicy do
  subject(:policy) { described_class.new(user, scope) }

  let(:scope) { create(:scope) }

  context "when user is a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_action :browse }
  end

  context "when user is a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to permit_action :browse }
  end

  context "when user is a data_help admin" do
    let(:user) { create(:admin, :data_help) }

    it { is_expected.to permit_action :browse }
  end

  context "when user is a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_action :browse }
  end

  it_behaves_like "a policy that forbids data modifications on slave mode"
end

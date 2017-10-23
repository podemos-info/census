# frozen_string_literal: true

require "rails_helper"

describe ScopePolicy do
  subject(:policy) { described_class.new(user, scope) }

  let(:scope) { create(:scope) }

  context "being a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_action :browse }
  end

  context "being a lopd admin" do
    let(:user) { create(:admin, :lopd) }

    it { is_expected.to permit_action :browse }
  end

  context "being a lopd_help admin" do
    let(:user) { create(:admin, :lopd_help) }

    it { is_expected.to permit_action :browse }
  end

  context "being a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_action :browse }
  end
end

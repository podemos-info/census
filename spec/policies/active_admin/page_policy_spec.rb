# frozen_string_literal: true

require "rails_helper"

describe ActiveAdmin::PagePolicy do
  subject(:policy) { described_class.new(user, page) }
  let(:page) { instance_double(ActiveAdmin::Page, name: name) }

  describe "Dashboard page" do
    let(:name) { "Dashboard" }
    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to permit_action :show }
    end

    context "being a lopd admin" do
      let(:user) { create(:admin, :lopd) }

      it { is_expected.to permit_action :show }
    end

    context "being a lopd_help admin" do
      let(:user) { create(:admin, :lopd_help) }

      it { is_expected.to permit_action :show }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to permit_action :show }
    end
  end

  describe "Other page" do
    let(:name) { "other" }
    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_action :show }
    end

    context "being a lopd admin" do
      let(:user) { create(:admin, :lopd) }

      it { is_expected.to forbid_action :show }
    end

    context "being a lopd_help admin" do
      let(:user) { create(:admin, :lopd_help) }

      it { is_expected.to forbid_action :show }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_action :show }
    end
  end
end

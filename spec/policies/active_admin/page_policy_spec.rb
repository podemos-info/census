# frozen_string_literal: true

require "rails_helper"

describe ActiveAdmin::PagePolicy do
  subject(:policy) { described_class.new(user, page) }

  let(:page) { instance_double(ActiveAdmin::Page, name: name) }

  describe "Dashboard page" do
    let(:name) { "Dashboard" }

    context "when user is a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to permit_actions([:show, :admins_stats]) }
      it { is_expected.to forbid_actions([:people_stats, :procedures_stats, :orders_stats]) }
    end

    context "when user is a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to permit_actions([:show, :people_stats, :procedures_stats, :admins_stats]) }
      it { is_expected.to forbid_actions([:orders_stats]) }
    end

    context "when user is a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to permit_actions([:show, :procedures_stats]) }
      it { is_expected.to forbid_actions([:people_stats, :admins_stats, :orders_stats]) }
    end

    context "when user is a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to permit_actions([:show, :orders_stats]) }
      it { is_expected.to forbid_actions([:people_stats, :procedures_stats, :admins_stats]) }
    end
  end

  describe "Other page" do
    let(:name) { "other" }

    context "when user is a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_action :show }
    end

    context "when user is a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to forbid_action :show }
    end

    context "when user is a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_action :show }
    end

    context "when user is a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_action :show }
    end
  end
end

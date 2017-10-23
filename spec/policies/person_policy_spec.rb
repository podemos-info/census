# frozen_string_literal: true

require "rails_helper"

describe PersonPolicy do
  subject(:policy) { described_class.new(user, person) }

  let(:person) { create(:person) }

  context "being a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a lopd admin" do
    let(:user) { create(:admin, :lopd) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a lopd_help admin" do
    let(:user) { create(:admin, :lopd_help) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end
end

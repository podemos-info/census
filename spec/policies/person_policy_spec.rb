# frozen_string_literal: true

require "rails_helper"

describe PersonPolicy do
  subject(:policy) { described_class.new(user, person) }

  let(:person) { create(:person) }

  context "being a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :request_verification }
    it { is_expected.to forbid_action :cancellation }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action :request_verification }
    it { is_expected.to permit_action :cancellation }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a data_help admin" do
    let(:user) { create(:admin, :data_help) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action :request_verification }
    it { is_expected.to permit_action :cancellation }
    it { is_expected.to forbid_action :destroy }
  end

  context "being a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :request_verification }
    it { is_expected.to forbid_action :cancellation }
    it { is_expected.to forbid_action :destroy }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe OrderPolicy do
  subject(:policy) { described_class.new(user, order) }

  let(:order) { create(:order) }

  context "when user is a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_actions([:index, :show]) }
    it { is_expected.to forbid_action :charge }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to forbid_actions([:index, :show, :charge]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a data_help admin" do
    let(:user) { create(:admin, :data_help) }

    it { is_expected.to forbid_actions([:index, :show, :charge]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to permit_actions([:index, :show, :charge]) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  it_behaves_like "a policy that forbids data modifications on slave mode" do
    let(:extra_actions) { [:charge] }
  end
end

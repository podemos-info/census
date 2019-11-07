# frozen_string_literal: true

require "rails_helper"

describe PersonLocationPolicy do
  subject(:policy) { described_class.new(user, person_location) }

  let(:person_location) { create(:person_location) }

  with_versioning do
    context "when user is a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to permit_actions([:index, :show]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to permit_actions([:index, :show]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_actions([:index, :show]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_actions([:index, :show]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end
  end

  it_behaves_like "a policy that forbits data modifications on slave mode"
end

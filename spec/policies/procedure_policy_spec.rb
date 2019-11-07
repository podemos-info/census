# frozen_string_literal: true

require "rails_helper"

describe ProcedurePolicy do
  subject(:policy) { described_class.new(user, procedure) }

  let(:procedure) { create(:document_verification) }

  context "when user is a system admin" do
    let(:user) { create(:admin) }

    it { is_expected.to permit_actions([:index, :show, :process, :undo, :view_attachment]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to permit_actions([:index, :show, :process, :undo, :view_attachment]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a data_help admin" do
    let(:user) { create(:admin, :data_help) }

    it { is_expected.to permit_actions([:index, :show, :process, :undo, :view_attachment]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  context "when user is a finances admin" do
    let(:user) { create(:admin, :finances) }

    it { is_expected.to forbid_actions([:index, :show, :process, :undo, :view_attachment]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :destroy }
  end

  describe "procedure with cancelled person" do
    let(:procedure) { create(:document_verification, :cancelled_person) }

    context "when user is a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_actions([:index, :show, :process, :undo, :view_attachment]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to permit_actions([:index, :show, :view_attachment]) }
      it { is_expected.to forbid_actions([:process, :undo]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_actions([:index, :show, :process, :undo, :view_attachment]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "when user is a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_actions([:index, :show, :process, :undo, :view_attachment]) }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end
  end

  it_behaves_like "a policy that forbits data modifications on slave mode" do
    let(:extra_actions) { [:undo] }
  end
end

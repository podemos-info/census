# frozen_string_literal: true

require "rails_helper"

describe IssuePolicy do
  subject(:policy) { described_class.new(user, issue) }

  context "for index pages (no specific issue)" do
    let(:issue) { Issue }

    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to permit_action :index }
    end

    context "being a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to permit_action :index }
    end

    context "being a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to permit_action :index }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to permit_action :index }
    end
  end

  context "for a data issue" do
    let(:issue) { create(:duplicated_document) }

    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end
  end

  context "for a finances issue" do
    let(:issue) { create(:missing_bic) }

    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end
  end

  context "for a system issue" do
    let(:issue) { create(:processing_issue, :system, issuable: order) }
    let(:order) { create(:order) }

    context "being a system admin" do
      let(:user) { create(:admin) }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data admin" do
      let(:user) { create(:admin, :data) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a data_help admin" do
      let(:user) { create(:admin, :data_help) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end

    context "being a finances admin" do
      let(:user) { create(:admin, :finances) }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action :destroy }
    end
  end
end

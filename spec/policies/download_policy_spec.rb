# frozen_string_literal: true

require "rails_helper"

describe DownloadPolicy do
  subject(:policy) { described_class.new(user, download) }

  let(:download) { create(:download) }

  context "when user is a data admin" do
    let(:user) { create(:admin, :data) }

    it { is_expected.to permit_actions([:index, :show, :download, :destroy]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action :recover }

    context "when download is discarded" do
      let(:download) { create(:download, :discarded) }

      it { is_expected.to permit_actions [:index, :show, :download, :recover] }
      it { is_expected.to forbid_action :destroy }
    end
  end

  %w(system data_help finances).each do |role|
    context "when user is a #{role} admin" do
      let(:user) { create(:admin, role) }

      it { is_expected.to permit_action :index }
      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_actions([:show, :download, :destroy, :recover]) }

      context "when the download is for me" do
        let(:download) { create(:download, person: user.person) }

        it { is_expected.to permit_actions([:index, :show, :download, :destroy]) }
        it { is_expected.to forbid_action :recover }

        context "when download is discarded" do
          let(:download) { create(:download, :discarded, person: user.person) }

          it { is_expected.to permit_actions([:index, :show, :download, :recover]) }
          it { is_expected.to forbid_action :destroy }
        end
      end

      it_behaves_like "a policy that forbids data modifications on slave mode"
    end
  end
end

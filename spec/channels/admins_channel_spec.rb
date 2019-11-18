# frozen_string_literal: true

require "rails_helper"

describe AdminsChannel, type: :channel do
  include_context "with a logged user for the channel" do
    let(:current_admin) { create(:admin, :data) }
  end

  it "successfully subscribes" do
    subscribe
    expect(subscription).to be_confirmed
  end

  shared_examples "broadcasts the admin status" do
    let(:count_unread_issues) { 0 }
    let(:count_running_jobs) { 0 }
    let(:count_active_downloads) { 0 }

    it "broadcast a new admin status" do
      expect { subject }.to have_broadcasted_to(current_admin).with(
        admin: { id: current_admin.id,
                 count_unread_issues: count_unread_issues, count_running_jobs: count_running_jobs,
                 count_active_downloads: count_active_downloads }
      )
    end
  end

  describe "#notify_change" do
    subject { described_class.notify_change(current_admin) }

    it_behaves_like "broadcasts the admin status"

    context "when admin has pending issues" do
      let(:issue_unread) { create(:issue_unread, admin: current_admin) }

      before { issue_unread }

      it_behaves_like "broadcasts the admin status" do
        let(:count_unread_issues) { 1 }
      end
    end

    context "when admin has running jobs" do
      let(:running_job) { create(:job, :running, user: current_admin) }

      before { running_job }

      it_behaves_like "broadcasts the admin status" do
        let(:count_running_jobs) { 1 }
      end
    end

    context "when admin has active downloads" do
      let(:download) { create(:download, person: current_admin.person) }

      before { download }

      it_behaves_like "broadcasts the admin status" do
        let(:count_active_downloads) { 1 }
      end
    end
  end
end

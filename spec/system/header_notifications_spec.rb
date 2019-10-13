# frozen_string_literal: true

require "rails_helper"

describe "Header notifications", type: :system, js: true, action_cable: :async do
  let(:current_admin) { create(:admin, :data) }

  before do
    login_as current_admin
  end

  it "shows no issues and no jobs" do
    visit root_path
    expect(page).to have_no_css("#admin_jobs.running")
    expect(page).to have_no_css("#admin_issues.unread")
  end

  context "when there are pending issues" do
    let(:issue_unread) { create(:issue_unread, admin: current_admin) }

    it "shows the ringing bell and no jobs" do
      issue_unread
      visit root_path
      expect(page).to have_css("#admin_issues.unread")
      expect(page).to have_no_css("#admin_jobs.running")
    end
  end

  context "when there are running jobs" do
    let(:job) { create(:job, :running, user: current_admin) }

    it "shows no issues and the spinning gear" do
      job
      visit root_path
      expect(page).to have_no_css("#admin_issues.unread")
      expect(page).to have_css("#admin_jobs.running")
    end
  end
end

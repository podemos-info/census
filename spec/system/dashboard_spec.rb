# frozen_string_literal: true

require "rails_helper"

describe "Dashboard", type: :system, js: true do
  let(:current_admin) { create(:admin) }

  before do
    login_as current_admin
  end

  it "shows admins stats" do
    visit root_path

    expect(page).not_to have_content("Atención: el sistema está en modo de solo lectura y no permite modificaciones.")
    expect(page).not_to have_css(".hide_buttons")

    expect(page).to have_css("#admins_stats")
    within("#admins_stats") do
      expect(page).not_to have_content("Error Loading Chart: Not Found")
    end

    expect(page).not_to have_css("#people_stats")
    expect(page).not_to have_css("#procedures_stats")
    expect(page).not_to have_css("#orders_stats")
  end

  context "when admin has data_help role" do
    let(:current_admin) { create(:admin, :data_help) }

    it "shows procedures stats" do
      visit root_path

      expect(page).to have_css("#procedures_stats")
      within("#procedures_stats") do
        expect(page).not_to have_content("Error Loading Chart: Not Found")
      end

      expect(page).not_to have_css("#people_stats")
      expect(page).not_to have_css("#admins_stats")
      expect(page).not_to have_css("#orders_stats")
    end
  end

  context "when admin has data role" do
    let(:current_admin) { create(:admin, :data) }

    it "shows people and procedures stats" do
      visit root_path

      expect(page).to have_css("#people_stats")
      within("#people_stats") do
        expect(page).not_to have_content("Error Loading Chart: Not Found")
      end

      expect(page).to have_css("#procedures_stats")
      within("#procedures_stats") do
        expect(page).not_to have_content("Error Loading Chart: Not Found")
      end

      expect(page).to have_css("#admins_stats")
      within("#admins_stats") do
        expect(page).not_to have_content("Error Loading Chart: Not Found")
      end

      expect(page).not_to have_css("#orders_stats")
    end
  end

  context "when admin has finances role" do
    let(:current_admin) { create(:admin, :finances) }

    it "shows orders stats" do
      visit root_path

      expect(page).not_to have_css("#people_stats")
      expect(page).not_to have_css("#procedures_stats")
      expect(page).not_to have_css("#admins_stats")

      expect(page).to have_css("#orders_stats")
      within("#orders_stats") do
        expect(page).not_to have_content("Error Loading Chart: Not Found")
      end
    end
  end

  context "when slave mode" do
    let(:current_admin) { create(:admin, :data) }

    include_context "when slave mode"

    it "shows admins stats" do
      visit root_path

      expect(page).to have_content("Atención: el sistema está en modo de solo lectura y no permite modificaciones.")
      expect(page).to have_css(".hide_buttons")
    end
  end
end

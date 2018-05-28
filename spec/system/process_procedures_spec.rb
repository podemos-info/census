# frozen_string_literal: true

require "rails_helper"

describe "Process procedure", type: :system do
  let(:current_admin) { create(:admin, :data) }

  before do
    login_as current_admin
    visit procedure_path(procedure)
  end

  with_versioning do
    [:document_verification, :membership_level_change, :registration, :person_data_change, :cancellation].each do |type|
      context "when accepting a #{type} procedure" do
        let(:procedure) { create(type) }

        it "marks procedure as accepted and hides the processing form" do
          expect(page).to have_content("Procesar")

          find("#procedure_action_accept").click
          find("#procedure_submit_action input[type=submit]").click

          expect(procedure.reload).to be_accepted

          visit procedure_path(procedure)

          expect(page).not_to have_content("Procesar")
        end
      end

      context "when rejecting a #{type} procedure" do
        let(:procedure) { create(type) }

        it "marks procedure as rejected and hides the processing form" do
          expect(page).to have_content("Procesar")

          find("#procedure_action_reject").click
          fill_in :procedure_comment, with: "Rejection explanation"
          find("#procedure_submit_action input[type=submit]").click

          expect(procedure.reload).to be_rejected

          visit procedure_path(procedure)

          expect(page).not_to have_content("Procesar")
        end
      end
    end
  end
end

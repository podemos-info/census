# frozen_string_literal: true

require "rails_helper"

describe "Process procedure", type: :system, js: true, action_cable: :async do
  let(:current_admin) { create(:admin, :data) }

  before do
    login_as current_admin
  end

  describe "locking and unlocking" do
    subject(:procedure) { create(:document_verification, processing_by: processing_by) }

    context "when a single admin access to the procedure" do
      let(:processing_by) { nil }

      it "locks and unlocks the procedure" do
        expect(procedure.processing_by).to be_nil

        visit procedure_path(procedure)

        expect(page).to have_content("Aceptar") # Very important: waits WebSockets to be working

        expect(procedure.reload.processing_by).to eq(current_admin)

        visit procedures_path

        expect(procedure.reload.processing_by).to be_nil
      end
    end

    context "when another user is processing the procedure" do
      let(:processing_by) { create(:admin, :data) }

      it "can't unlock the procedure, unless forcing it" do
        expect(procedure.processing_by).to eq(processing_by)

        visit procedure_path(procedure)

        expect(page).to have_content("El procedimiento esta siendo procesado")
        expect(page).not_to have_content("Aceptar")

        click_on "Haz click aquí para procesarlo de todos modos"

        expect(page).to have_content("Aceptar") # Very important: waits WebSockets to be working
        expect(procedure.reload.processing_by).to eq(current_admin)

        visit procedures_path

        expect(procedure.reload.processing_by).to be_nil
      end
    end
  end

  describe "different procedures processing" do
    before do
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

      context "when accepting a verification procedure with a pending membership_level_change procedure" do
        let(:dependent_procedure) { create(:membership_level_change, :not_acceptable, to_membership_level: "member") }
        let(:procedure) { create(:document_verification, person: person) }
        let(:person) { dependent_procedure.person }

        it "marks procedure as accepted and person membership_level is changed" do
          expect(page).to have_content("Procesar")

          perform_enqueued_jobs do
            find("#procedure_action_accept").click
            find("#procedure_submit_action input[type=submit]").click
            visit procedure_path(procedure)
          end

          expect(procedure.reload).to be_accepted

          expect(page).not_to have_content("Procesar")

          visit procedure_path(dependent_procedure)

          expect(page).not_to have_content("Procesar")

          expect(person.reload).to be_member
        end
      end
    end
  end
end

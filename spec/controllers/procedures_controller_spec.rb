# frozen_string_literal: true

require "rails_helper"

describe ProceduresController, type: :controller do
  render_views
  include_context "with a devise login"

  let(:processed_by) { create(:admin) }
  let(:resource_class) { Procedure }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let(:procedure) { create(:document_verification, :with_attachments) }

  describe "active admin resource" do
    before { procedure && processed_by }

    it "defines actions" do
      expect(resource.defined_actions).to contain_exactly(:index, :show, :update)
    end

    it "handles procedures" do
      expect(resource.resource_name).to eq("Procedure")
    end

    it "shows menu" do
      expect(resource).to be_include_in_menu
    end
  end

  with_versioning do
    describe "index page" do
      subject { get :index, params: params }

      before { procedure && autoprocessed_procedure }

      let(:autoprocessed_procedure) { create(:registration, :autoprocessed) }
      let(:params) { {} }

      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("index") }

      include_examples "tracks the user visit"

      it_behaves_like "a controller that allows fast filter" do
        let(:procedure) { create(:registration, person: person, person_copy_data: person) }
        let(:person) { create(:person, first_name: "Miguel", last_name1: "Serveto", last_name2: "Conesa") }
        let(:fast_filter) { "Miguel Servet" }
        let(:result) { "Serveto Conesa, Miguel" }
      end

      context "with accepted tab" do
        let(:params) { { scope: :accepted } }
        let(:current_admin) { procedure.processed_by }
        let(:procedure) { create(:document_verification, :undoable) }

        it { expect(subject).to be_successful }
        it { expect(subject).to render_template("index") }
      end
    end

    describe "show procedure" do
      subject { get :show, params: { id: procedure.id } }

      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("show") }

      include_examples "has comments enabled"
      include_examples "tracks the user visit"

      context "when has a closed issue" do
        before { closed_issue }

        let(:closed_issue) { create(:duplicated_person, :ready_to_fix, :fixed, issuable: procedure) }
        let(:current_admin) { create(:admin, :data) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }

        it "doesn't show an error message" do
          expect { subject } .not_to change { flash[:alert] } .from(nil)
        end

        it "shows the procedure processing form" do
          expect(subject.body).to include("procedure_action_input")
        end

        context "when has a open issue too" do
          before { open_issue }

          let(:open_issue) { create(:duplicated_document, issuable: procedure) }

          it { is_expected.to be_successful }
          it { is_expected.to render_template("show") }

          it "shows an error message" do
            expect { subject }
              .to change { flash[:alert] }
              .from(nil)
              .to "¡Atención! Hay incidencias abiertas asociadas a este registro: "\
                  "<a class=\"member_link\" href=\"/issues/#{open_issue.id}/edit\">Documento duplicado ##{open_issue.id}</a>."
          end

          it "doesn't show the procedure processing form" do
            expect(subject.body).not_to include("procedure_action_input")
          end
        end
      end
    end

    describe "show processed procedure" do
      subject { get :show, params: { id: procedure.id } }

      let!(:procedure) { create(:document_verification, :processed) }

      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("show") }

      include_examples "tracks the user visit"
    end

    describe "next pending procedure" do
      subject { get :next_document_verification }

      before { old_procedure && non_prioritized_procedure && procedure && second_procedure }

      let(:old_procedure) { create(:document_verification, created_at: 2.years.ago, prioritized_at: 1.year.ago) }
      let(:procedure) { create(:document_verification, :prioritized, created_at: 6.months.ago) }
      let(:second_procedure) { create(:document_verification, :prioritized, created_at: 2.months.ago) }
      let(:non_prioritized_procedure) { create(:document_verification, created_at: 11.months.ago) }

      it "redirect to the right pending procedure page" do
        expect(subject).to redirect_to(procedure_path(procedure))
      end

      include_examples "tracks the user visit"

      context "when there are not pending prioritized procedures" do
        let(:old_procedure) { create(:document_verification, created_at: 2.years.ago) }
        let(:procedure) { create(:document_verification, created_at: 6.months.ago) }
        let(:second_procedure) { create(:document_verification, created_at: 2.months.ago) }

        it "redirect to the right pending procedure page" do
          expect(subject).to redirect_to(procedure_path(old_procedure))
        end
      end

      context "when there are not pending procedures" do
        let(:old_procedure) { true }
        let(:procedure) { true }
        let(:second_procedure) { true }
        let(:non_prioritized_procedure) { true }

        it "shows a notice message" do
          subject
          expect(flash[:notice]).to be_present
        end

        it "redirect to the right pending procedure page" do
          expect(subject).to redirect_to(procedures_path)
        end
      end
    end

    describe "trying to undone when not undoable" do
      subject { patch :undo, params: { id: procedure.id } }

      it "returns an error" do
        subject
        expect(flash[:error]).to be_present
      end

      it "redirect to procedures page" do
        expect(subject).to redirect_to(procedures_path)
      end

      include_examples "tracks the user visit"
    end

    describe "undoable procedure" do
      let!(:procedure) { create(:document_verification, :undoable) }
      let(:current_admin) { procedure.processed_by }

      describe "index page" do
        subject { get :index }

        it { expect(subject).to be_successful }
        it { expect(subject).to render_template("index") }
      end

      describe "show" do
        subject { get :show, params: { id: procedure.id } }

        it { expect(subject).to be_successful }
        it { expect(subject).to render_template("show") }
      end

      describe "undo" do
        subject { patch :undo, params: { id: procedure.id, lock_version: lock_version } }

        let(:lock_version) { procedure.lock_version }

        it "notifies that it was ok" do
          subject
          expect(flash[:notice]).to be_present
        end

        it "redirect to procedures page" do
          expect(subject).to redirect_to(procedures_path)
        end

        it "have undone the procedure" do
          expect { subject } .to change { Procedure.find(procedure.id).state } .to("pending")
        end

        it_behaves_like "an admin page that forbids modifications on slave mode"

        context "when saving fails" do
          before { stub_command("Procedures::UndoProcedure", :error) }

          it { is_expected.to redirect_to(procedures_path) }

          it "shows an error message" do
            expect { subject }
              .to change { flash[:error] }
              .from(nil)
              .to("Ha ocurrido un error al intentar devolver procedimiento <a href=\"/procedures/#{procedure.id}\">#{procedure.id}</a> a su estado anterior.")
          end
        end

        context "when procedure has changes while the undoing" do
          let(:lock_version) { procedure.lock_version - 1 }

          it { is_expected.to redirect_to(procedures_path) }
          it { expect { subject } .to change { flash[:error] } .from(nil).to("El procedimiento ha sido modificado por otra persona.") }

          it "does not reject the procedure" do
            expect { subject } .not_to change { Procedure.find(procedure.id).state }
          end
        end
      end
    end
  end

  describe "update page" do
    subject { patch :update, params: { id: procedure.id, procedure: params } }

    let(:params) { { action: "reject", comment: Faker::Lorem.paragraph(1, true, 2) } }

    it { is_expected.to redirect_to(procedures_path) }

    it "rejects the procedure" do
      expect { subject } .to change { Procedure.find(procedure.id).state }.from("pending").to("rejected")
    end

    include_examples "tracks the user visit"

    it_behaves_like "an admin page that forbids modifications on slave mode"

    context "when creating an issue" do
      let(:params) { { action: "issue", comment: Faker::Lorem.paragraph(1, true, 2) } }

      it { expect(subject).to redirect_to(procedures_path) }

      it "creates the issue for the procedure" do
        expect { subject } .to change { Procedure.find(procedure.id).issues.count } .by(1)
      end

      context "when saving fails" do
        before { stub_command("Procedures::ProcessProcedure", :issue_error) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
        it { expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al abrir la incidencia.") }
      end
    end

    context "when there are missing params" do
      let(:params) { { action: "reject" } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      it "does not reject the procedure" do
        expect { subject } .not_to change { Procedure.find(procedure.id).state }.from("pending")
      end
    end

    context "when saving fails" do
      before { stub_command("Procedures::ProcessProcedure", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al procesar el procedimiento.") }
    end

    context "when another user has started to process the procedure while the processing" do
      before do
        procedure.processing_by = another_admin
        procedure.save!
      end

      let(:another_admin) { create(:admin) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("El procedimiento está siendo procesado por otra persona.") }

      it "does not reject the procedure" do
        expect { subject } .not_to change { Procedure.find(procedure.id).state }.from("pending")
      end
    end
  end

  describe "download attachment" do
    subject { get :view_attachment, params: { id: procedure.id, attachment_id: procedure.attachments.first.id } }

    it { expect(subject).to be_successful }
    it { expect(subject.content_type).to eq("image/png") }
    it { expect(subject.body).to eq(procedure.attachments.first.file.read) }

    include_examples "tracks the user visit"
  end
end

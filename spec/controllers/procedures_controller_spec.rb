# frozen_string_literal: true

require "rails_helper"

describe ProceduresController, type: :controller do
  render_views
  include_context "devise login"

  let!(:processed_by) { create(:admin) }
  let(:resource_class) { Procedure }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let!(:procedure) { create(:document_verification, :with_attachments, :with_dependent_procedure) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :update)
  end

  it "handles procedures" do
    expect(resource.resource_name).to eq("Procedure")
  end

  it "shows menu" do
    expect(resource).to be_include_in_menu
  end

  with_versioning do
    context "index page" do
      subject { get :index }
      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("index") }

      context "accepted tab" do
        subject { get :index, params: { scope: :accepted } }
        let(:current_admin) { procedure.processed_by }
        let!(:procedure) { create(:document_verification, :undoable) }
        it { expect(subject).to be_successful }
        it { expect(subject).to render_template("index") }
      end
    end

    context "show procedure" do
      subject { get :show, params: { id: procedure.id } }
      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("show") }
    end

    context "show processed procedure" do
      let!(:procedure) { create(:document_verification, :processed) }
      subject { get :show, params: { id: procedure.id } }
      it { expect(subject).to be_successful }
      it { expect(subject).to render_template("show") }
    end

    context "trying to undone when not undoable" do
      subject { patch :undo, params: { id: procedure.id } }

      it "returns an error" do
        expect(subject).to redirect_to(procedures_path)
        expect(flash[:error]).to be_present
      end
    end

    context "undoable procedure" do
      let!(:procedure) { create(:document_verification, :undoable) }
      let(:current_admin) { procedure.processed_by }

      context "index page" do
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
        subject { patch :undo, params: { id: procedure.id } }

        it "returns ok" do
          expect(subject).to redirect_to(procedures_path)
          expect(flash[:notice]).to be_present
        end

        it "should have undone the procedure" do
          expect { subject } .to change { Procedure.find(procedure.id).state } .to("pending")
        end

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
        expect { subject } .to_not change { Procedure.find(procedure.id).state }.from("pending")
      end
    end

    context "when saving fails" do
      before { stub_command("Procedures::ProcessProcedure", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al procesar el procedimiento.") }
    end
  end

  context "download attachment" do
    subject { get :view_attachment, params: { id: procedure.id, attachment_id: procedure.attachments.first.id } }
    it { expect(subject).to be_successful }
    it { expect(subject.content_type).to eq("image/png") }
    it { expect(subject.body).to eq(procedure.attachments.first.file.read) }
  end
end

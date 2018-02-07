# frozen_string_literal: true

require "rails_helper"

describe ProceduresController, type: :controller do
  render_views
  include_context "devise login"

  let!(:processed_by) { create(:admin) }
  let(:resource_class) { Procedure }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let!(:procedure) { create(:verification_document, :with_attachments, :with_dependent_procedure) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :edit, :update)
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
      it { expect(subject).to be_success }
      it { expect(subject).to render_template("index") }

      context "accepted tab" do
        subject { get :index, params: { scope: :accepted } }
        let(:current_admin) { procedure.processed_by }
        let!(:procedure) { create(:verification_document, :undoable) }
        it { expect(subject).to be_success }
        it { expect(subject).to render_template("index") }
      end
    end

    context "show procedure" do
      subject { get :show, params: { id: procedure.id } }
      it { expect(subject).to be_success }
      it { expect(subject).to render_template("show") }
    end

    context "show processed procedure" do
      let!(:procedure) { create(:verification_document, :processed) }
      subject { get :show, params: { id: procedure.id } }
      it { expect(subject).to be_success }
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
      let!(:procedure) { create(:verification_document, :undoable) }

      describe "show" do
        subject { get :show, params: { id: procedure.id } }
        it { expect(subject).to be_success }
        it { expect(subject).to render_template("show") }
      end

      describe "undo" do
        subject { patch :undo, params: { id: procedure.id } }
        let(:current_admin) { procedure.processed_by }

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
            subject
            expect(flash[:error]).to be_present
          end
        end
      end
    end
  end

  context "edit procedure" do
    subject { get :edit, params: { id: procedure.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  context "edit processed procedure" do
    let(:procedure) { create(:verification_document, :processed) }
    subject { get :edit, params: { id: procedure.id } }
    it { expect(subject).to redirect_to(procedures_path) }
  end

  describe "update page" do
    subject { patch :update, params: { id: procedure.id, procedure: params } }
    let(:params) { { event: "reject", comment: Faker::Lorem.paragraph(1, true, 2) } }

    it { expect(subject).to redirect_to(procedures_path) }

    it "should have accepted the procedure" do
      expect { subject } .to change { Procedure.find(procedure.id).state }.from("pending").to("rejected")
    end

    context "when there are missing params" do
      let(:params) { { event: "reject" } }

      it { is_expected.to be_success }
      it { is_expected.to render_template("edit") }

      it "should have not rejected the procedure" do
        expect { subject } .to_not change { Procedure.find(procedure.id).state }.from("pending")
      end
    end

    context "when saving fails" do
      before { stub_command("Procedures::ProcessProcedure", :error) }

      it { is_expected.to be_success }
      it { is_expected.to render_template("edit") }

      it "shows an error message" do
        subject
        expect(flash[:error]).to be_present
      end
    end
  end

  context "download attachment" do
    subject { get :view_attachment, params: { id: procedure.id, attachment_id: procedure.attachments.first.id } }
    it { expect(subject).to be_success }
    it { expect(subject.content_type).to eq("image/png") }
    it { expect(subject.body).to eq(procedure.attachments.first.file.read) }
  end
end

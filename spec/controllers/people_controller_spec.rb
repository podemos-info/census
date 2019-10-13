# frozen_string_literal: true

require "rails_helper"

describe PeopleController, type: :controller do
  render_views
  include_context "with a devise login"

  before { person && person_location && issue }

  let(:resource_class) { Person }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let(:person) { create(:person, first_name: "Miguel", last_name1: "Serveto", last_name2: "Conesa", email: "mserveto@example.org") }
  let(:person_location) { create(:person_location, person: person) }
  let(:issue) { create(:duplicated_document) } # creates a pending person with a procedure and an issue
  let(:current_admin) { create(:admin, :data) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :edit, :update)
  end

  it "handles people" do
    expect(resource.resource_name).to eq("Person")
  end

  it "shows menu" do
    expect(resource).to be_include_in_menu
  end

  describe "index page" do
    subject { get :index, params: params }

    let(:params) { {} }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"

    it_behaves_like "a controller that allows fast filter" do
      let(:fast_filter) { "Miguel Servet" }
      let(:result) { "Serveto Conesa, Miguel" }
    end

    context "when filtered by pending people" do
      let(:params) { { scope: "pending" } }

      it { is_expected.to be_successful }
    end

    context "when ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }

      it { is_expected.to be_successful }
    end

    context "when ordered by full_document" do
      let(:params) { { order: "full_document_asc" } }

      it { is_expected.to be_successful }
    end

    context "when ordered by scope" do
      let(:params) { { order: "scope_desc" } }

      it { is_expected.to be_successful }
    end
  end

  describe "edit page" do
    subject { get :edit, params: { id: person.id } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("edit") }

    include_examples "tracks the user visit"
  end

  with_versioning do
    before "creates a version for the person" do
      person.update! first_name: "original" # creates an update person version
    end

    describe "show page" do
      subject { get :show, params: { id: person.id } }

      before { download }

      let(:download) { create(:download, person: person) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "has comments enabled"
      include_examples "tracks the user visit"

      context "when accessing as finances admin" do
        before { order }

        let(:current_admin) { create(:admin, :finances) }
        let(:order) { create(:order, person: person) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
      end
    end

    describe "update page" do
      subject do
        person.assign_attributes changed_attributes
        patch :update, params: { id: person.id, person: person.attributes }
      end

      let(:changed_attributes) { { first_name: first_name } }
      let(:first_name) { "changed" }

      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(person_url(person.id)) }
      it { expect { subject } .to change(person, :first_name).from("original").to("changed") }

      include_examples "tracks the user visit"

      context "when changes the person email" do
        let(:changed_attributes) { { email: "mserveto2@example.org" } }
        let(:notice_message) do
          "Se ha solicitado el envío de un correo para que se verifique el cambio de dirección. Si dicho correo "\
          "no llega a su destino se debe a que ya existe otra inscripción con dicha dirección de correo. En ese "\
          "caso, será necesaria que la persona que controla dicha cuenta cambie su dirección de correo por otra "\
          "para volver a solicitar este cambio."
        end

        it { is_expected.to have_http_status(:found) }
        it { expect(subject.location).to eq(person_url(person.id)) }

        it "shows an error message" do
          expect { subject } .to change { flash[:notice] } .from(nil).to(notice_message)
        end
      end

      context "when nothing changes" do
        let(:first_name) { person.first_name }

        it { is_expected.to have_http_status(:found) }
        it { expect(subject.location).to eq(person_url(person.id)) }

        it "shows an error message" do
          expect { subject } .to change { flash[:notice] } .from(nil).to("No se han realizado cambios.")
        end
      end

      context "with invalid params" do
        let(:first_name) { "" }

        it { expect { subject } .not_to change { person.reload.first_name } }
        it { is_expected.to be_successful }
        it { is_expected.to render_template("edit") }
      end

      context "when saving fails" do
        before { stub_command("People::CreatePersonDataChange", :error) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("edit") }

        it "shows an error message" do
          expect { subject } .to change { flash.now[:error] } .from(nil).to("Ha ocurrido un error al guardar el registro.")
        end
      end
    end

    describe "request verification" do
      subject { patch :request_verification, params: { id: person.id } }

      it { is_expected.to redirect_to(person_path(person)) }

      it "shows a notice message" do
        expect { subject }
          .to change { flash[:notice] }
          .from(nil)
          .to("Se ha enviado la solicitud de verificación a <a href=\"/people/#{person.id}\">#{person.id}</a>.")
      end

      it "changes the person verification state" do
        expect { subject } .to change { person.reload.verification } .from("not_verified").to("verification_requested")
      end

      include_examples "tracks the user visit"

      context "when trying to request verification to a verified person" do
        let(:person) { create(:person, :verified) }

        it { is_expected.to redirect_to(person_path(person)) }

        it "shows an error message" do
          expect { subject }
            .to change { flash[:error] }
            .from(nil)
            .to("No se puede solicitar a <a href=\"/people/#{person.id}\">#{person.id}</a> que se verifique.")
        end
      end

      context "when saving fails" do
        before { stub_command("People::RequestVerification", :error) }

        it { is_expected.to redirect_to(person_path(person)) }

        it "shows an error message" do
          expect { subject }
            .to change { flash[:error] }
            .from(nil)
            .to("Ha ocurrido un error al intentar solicitar a <a href=\"/people/#{person.id}\">#{person.id}</a> que se verifique.")
        end
      end
    end

    describe "cancellation" do
      subject { get :cancellation, params: { id: person.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("cancellation") }

      include_examples "tracks the user visit"

      context "when submitting data" do
        subject { patch :cancellation, params: { id: person.id, channel: channel, reason: reason } }

        let(:channel) { "email" }
        let(:reason) { "Razones de peso" }

        it { is_expected.to redirect_to(person_path(person)) }

        it "shows a notice message" do
          expect { subject }
            .to change { flash[:notice] }
            .from(nil)
            .to("Se ha creado el procedimiento de baja.")
        end

        it "changes the person state" do
          perform_enqueued_jobs do
            expect { subject } .to change { person.reload.state } .from("enabled").to("cancelled")
          end
        end

        context "with invalid params" do
          let(:channel) { "" }

          it { is_expected.to be_successful }
          it { is_expected.to render_template("cancellation") }
        end

        context "when saving fails" do
          before { stub_command("People::CreateCancellation", :error) }

          it { is_expected.to be_successful }
          it { is_expected.to render_template("cancellation") }

          it "shows an error message" do
            expect { subject }
              .to change { flash[:error] }
              .from(nil)
              .to("Ha ocurrido un error al guardar el registro.")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe PeopleController, type: :controller do
  render_views
  include_context "devise login"

  let(:resource_class) { Person }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let!(:person) { create(:person) }
  let!(:issue) { create(:duplicated_document) } # creates a pending person with a procedure and an issue
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

    context "pending people" do
      let(:params) { { scope: "pending" } }
      it { is_expected.to be_successful }
    end
    context "ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }
      it { is_expected.to be_successful }
    end
    context "ordered by full_document" do
      let(:params) { { order: "full_document_asc" } }
      it { is_expected.to be_successful }
    end
    context "ordered by scope" do
      let(:params) { { order: "scope_desc" } }
      it { is_expected.to be_successful }
    end
  end

  describe "edit page" do
    subject { get :edit, params: { id: person.id } }
    it { is_expected.to be_successful }
    it { is_expected.to render_template("edit") }
  end

  with_versioning do
    before "creates a version for the person" do
      person.update! first_name: "original" # creates an update person version
    end

    describe "show page" do
      subject { get :show, params: { id: person.id } }
      let!(:download) { create(:download, person: person) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      context "when accessing as finances admin" do
        let(:current_admin) { create(:admin, :finances) }
        let!(:order) { create(:order, person: person) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
      end
    end

    describe "update page" do
      subject do
        person.assign_attributes first_name: first_name
        patch :update, params: { id: person.id, person: person.attributes }
      end
      let(:first_name) { "changed" }

      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(person_url(person.id)) }
      it { expect { subject } .to change { person.first_name }.from("original").to("changed") }

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

      it "should change the person verification state" do
        expect { subject } .to change { person.reload.verification } .from("not_verified").to("verification_requested")
      end

      context "trying to request verification to a verified person" do
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

        it "should change the person state" do
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

# frozen_string_literal: true

require "rails_helper"

describe ProceduresController, type: :controller do
  let(:resource_class) { Procedure }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:resource) { all_resources[resource_class] }
  let(:procedure) { create(:verification_document) }

  it "defines actions" do
    expect(resource.defined_actions).to contain_exactly(:index, :show, :edit, :update)
  end

  it "handles procedures" do
    expect(resource.resource_name).to eq("Procedure")
  end

  it "shows menu" do
    expect(resource).to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("index") }
  end

  context "show page" do
    subject { get :show, params: { id: procedure.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("show") }
  end

  context "edit page" do
    subject { get :edit, params: { id: procedure.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  context "update page" do
    subject { patch :update, params: { id: procedure.id, procedure: { event: "accept", comment: Faker::Lorem.paragraph(1, true, 2) } } }
    it { expect(subject).to redirect_to(procedures_path) }

    it "should have accepted the procedure" do
      subject.code == "302" && procedure.reload
      expect(procedure.state).to eq("accepted")
    end
  end

  context "update error page" do
    subject { patch :update, params: { id: procedure.id, procedure: { event: "reject" } } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }

    it "should have not rejected the procedure" do
      subject.success? && procedure.reload
      expect(procedure.state).to eq("pending")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe PaymentMethodsController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { PaymentMethod }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:payment_method) { create(:credit_card, :external_verified) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :new, :show, :create, :destroy, :edit, :update)
  end

  it "handles payment methods" do
    expect(subject.resource_name).to eq("PaymentMethod")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"
  end

  with_versioning do
    describe "show page" do
      subject { get :show, params: { id: payment_method.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "tracks the user visit"
    end
  end

  describe "new page" do
    subject { get :new, params: { payment_method: { person_id: person.id } } }

    let(:person) { create(:person) }

    it { expect(subject).to be_successful }
    it { expect(subject).to render_template("new") }

    include_examples "tracks the user visit"
  end

  describe "create page" do
    subject { put :create, params: { person_id: person.id, payment_method: payment_method.attributes.merge(payment_method.additional_information) } }

    let(:payment_method) { build(:direct_debit, person: person) }
    let(:person) { create(:person) }

    it { expect { subject } .to change(PaymentMethod, :count).by(1) }
    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(person_payment_method_url(person, PaymentMethod.last)) }

    include_examples "tracks the user visit"

    context "when saving fails" do
      before { stub_command("Payments::SavePaymentMethod", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("new") }
    end
  end

  describe "edit page" do
    subject { get :edit, params: { id: payment_method.id } }

    it { expect(subject).to be_successful }
    it { expect(subject).to render_template("edit") }

    include_examples "tracks the user visit"
  end

  describe "update page" do
    subject do
      payment_method.assign_attributes name: "KKKKKK"
      patch :update, params: { id: payment_method.id, payment_method: payment_method.attributes }
    end

    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(payment_method_url(payment_method)) }
    it { expect { subject } .to change(payment_method, :name).to("KKKKKK") }

    include_examples "tracks the user visit"

    context "when saving fails" do
      before { stub_command("Payments::SavePaymentMethod", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("edit") }
    end
  end
end

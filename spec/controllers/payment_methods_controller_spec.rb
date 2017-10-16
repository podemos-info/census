# frozen_string_literal: true

require "rails_helper"

describe PaymentMethodsController, type: :controller do
  render_views
  include_context "devise login"

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

  context "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  with_versioning do
    context "show page" do
      subject { get :show, params: { id: payment_method.id } }
      it { is_expected.to be_success }
      it { is_expected.to render_template("show") }
    end
  end

  context "show page with system issues" do
    let!(:payment_method) { create(:direct_debit, system_issues: true) }
    subject { get :show, params: { id: payment_method.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  describe "dismiss payment method issues" do
    subject { get :dismiss_issues, params: params }
    let(:params) { { id: payment_method.id, issues_type: issues_type } }
    let!(:payment_method) { create(:direct_debit, issues_type => true) }
    let(:issues_type) { :admin_issues }

    context "admin issues" do
      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(payment_method_url(payment_method)) }
    end

    context "system issues" do
      let(:issues_type) { :system_issues }
      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(payment_method_url(payment_method)) }
    end

    context "without issues type" do
      let(:params) { { id: payment_method.id } }
      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(payment_method_url(payment_method)) }
    end
  end

  context "new page" do
    let(:person) { create(:person) }
    subject { get :new, params: { payment_method: { person_id: person.id } } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("new") }
  end

  context "create page" do
    let(:payment_method) { build(:direct_debit, person: person) }
    let(:person) { create(:person) }
    subject { put :create, params: { person_id: person.id, payment_method: payment_method.attributes.merge(payment_method.additional_information) } }
    it { expect { subject } .to change { PaymentMethod.count }.by(1) }
    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(person_payment_method_url(person, PaymentMethod.last)) }
  end

  context "edit page" do
    subject { get :edit, params: { id: payment_method.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end
end

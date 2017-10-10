# frozen_string_literal: true

require "rails_helper"

describe PaymentMethodsController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { PaymentMethod }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:payment_method) { create(:direct_debit) }

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
end

# frozen_string_literal: true

require "rails_helper"

describe OrdersController, type: :controller do
  render_views

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { Order }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:order) { create(:order) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show, :new, :create)
  end

  it "handles orders" do
    expect(subject.resource_name).to eq("Order")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  context "index page" do
    subject { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "show page" do
    subject { get :show, params: { id: order.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  context "new order" do
    subject { get :new }
    it "redirects to index page" do
      is_expected.to redirect_to(orders_path)
    end

    it "shows an error message" do
      subject
      expect(flash[:alert]).to be_present
    end
  end

  context "new order for a person page" do
    subject { get :new, params: { order: { person_id: order.person_id } } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  context "new order for a payment method page" do
    subject { get :new, params: { order: { payment_method_id: order.payment_method_id } } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  context "create order" do
    let(:payment_method) { nil }
    let(:order) { build(:order, payment_method: payment_method) }
    subject(:page) { put :create, params: { order: order.attributes } }

    context "with external authorization payment method" do
      it "does not increment the number of orders" do
        expect { subject } .not_to change { Order.count }
      end
      it "generate the form with the data for the payment" do
        is_expected.to render_template("orders/payment_form")
      end
    end

    context "with an existing payment_method" do
      let(:payment_method) { create(:credit_card) }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "increments the number of orders" do
        expect { subject } .to change { Order.count }.by(1)
      end
      it "shows the created order" do
        expect(subject.location).to eq(order_url(Order.last))
      end
    end
  end
end
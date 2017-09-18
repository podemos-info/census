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
    subject(:page) { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  context "show page" do
    subject(:page) { get :show, params: { id: order.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  context "new order" do
    subject(:page) { get :new }
    it "redirects to index page" do
      is_expected.to redirect_to(orders_path)
    end

    it "shows an error message" do
      subject
      expect(flash[:alert]).to be_present
    end
  end

  context "new order for a person page" do
    subject(:page) { get :new, params: { order: { person_id: order.person_id } } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  context "new order for a payment method page" do
    subject(:page) { get :new, params: { order: { payment_method_id: order.payment_method_id } } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("new") }
  end

  context "create order" do
    subject(:page) { put :create, params: { order: order.attributes } }
    let(:payment_method) { nil }
    let(:order) { build(:order, payment_method: payment_method) }

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

  context "charge credit card order" do
    subject(:page) do
      VCR.use_cassette(cassete) do
        patch :charge, params: { id: order.id }
      end
    end

    context "with a valid authorization token" do
      let(:payment_method) { create(:credit_card, :external_authorized) }
      let(:order) { create(:order, payment_method: payment_method) }
      let(:cassete) { "credit_card_payment_valid" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "sets the order as processed" do
        expect { subject } .to change { Order.find(order.id).state } .from("pending").to("processed")
      end
      it "saves the server response" do
        expect { subject } .to change { Order.find(order.id).raw_response } .from(nil)
      end
    end

    context "with an invalid authorization token" do
      let(:payment_method) { create(:credit_card, :external_authorized, authorization_token: "test") }
      let(:order) { create(:order, payment_method: payment_method) }
      let(:cassete) { "credit_card_payment_invalid" }

      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "set the order as error" do
        expect { subject } .to change { Order.find(order.id).state } .from("pending").to("error")
      end
      it "saves the server response" do
        expect { subject } .to change { Order.find(order.id).raw_response } .from(nil)
      end
    end

    context "with a processed order" do
      let(:cassete) { "processed_order" }
      let(:order) { create(:order, :processed) }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows an error message" do
        subject
        expect(flash[:error]).to be_present
      end
      it "shows the index page" do
        expect(subject.location).to eq(orders_url)
      end
    end
  end

  context "external payment result page" do
    subject(:page) { get :external_payment_result, params: { result: result } }

    context "when payment was ok" do
      let(:result) { "ok" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows an ok message" do
        subject
        expect(flash[:notice]).to be_present
      end
      it "shows the index page" do
        expect(subject.location).to eq(orders_url)
      end
    end

    context "when payment was ko" do
      let(:result) { "ko" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows an error message" do
        subject
        expect(flash[:error]).to be_present
      end
      it "shows the index page" do
        expect(subject.location).to eq(orders_url)
      end
    end
  end
end

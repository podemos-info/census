# frozen_string_literal: true

require "rails_helper"

describe OrdersController, type: :controller do
  render_views
  include_context "with a devise login"

  subject(:resource) { all_resources[resource_class] }

  let(:resource_class) { Order }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:order) { create(:order, :external_verified) }
  let(:current_admin) { create(:admin, :finances) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show, :new, :create)
  end

  it "handles orders" do
    expect(subject.resource_name).to eq("Order")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  describe "index page" do
    subject(:page) { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("index") }

    include_examples "tracks the user visit"
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get :show, params: { id: order.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "has comments enabled"
      include_examples "tracks the user visit"
    end
  end

  describe "new order" do
    subject(:page) { get :new }

    it { expect { subject } .to change { flash[:alert] } .from(nil).to("Puedes crear órdenes desde la página de una persona o un método de pago.") }

    it "redirects to index page" do
      is_expected.to redirect_to(orders_path)
    end

    include_examples "tracks the user visit"
  end

  describe "new order for a person page" do
    subject(:page) { get :new, params: { order: { person_id: order.person_id } } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("new") }

    include_examples "tracks the user visit"
  end

  describe "new order for a payment method page" do
    subject(:page) { get :new, params: { order: { payment_method_id: order.payment_method_id } } }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("new") }

    include_examples "tracks the user visit"
  end

  describe "create order" do
    subject(:page) { put :create, params: { order: order.attributes.merge(campaign_code: "test") } }

    let(:payment_method) { nil }
    let(:order) { build(:order, payment_method: payment_method) }

    it "increment the number of orders" do
      expect { subject } .to change(Order, :count)
    end

    it "generate the form with the data for the payment" do
      is_expected.to render_template("orders/payment_form")
    end

    include_examples "tracks the user visit"

    it_behaves_like "an admin page that forbids modifications on slave mode"

    context "with an existing payment_method" do
      let(:payment_method) { create(:credit_card) }

      it { is_expected.to have_http_status(:found) }

      it "increments the number of orders" do
        expect { subject } .to change(Order, :count).by(1)
      end

      it "shows the created order" do
        expect(subject.location).to eq(order_url(Order.last))
      end
    end

    context "when saving fails" do
      before { stub_command("Payments::CreateOrder", :error) }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("new") }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al guardar el registro.") }
    end
  end

  describe "charge credit card order" do
    subject(:page) do
      VCR.use_cassette(cassete) do
        patch :charge, params: { id: order.id }
      end
    end

    let(:payment_method) { create(:credit_card, :external_verified) }
    let(:order) { create(:order, payment_method: payment_method) }
    let(:cassete) { "credit_card_payment_valid" }

    it { is_expected.to have_http_status(:found) }

    it_behaves_like "an admin page that forbids modifications on slave mode"

    it "sets the order as processed" do
      expect { subject } .to change { Order.find(order.id).state } .from("pending").to("processed")
    end

    it "saves the server response" do
      expect { subject } .to change { Order.find(order.id).raw_response } .from(nil)
    end

    context "with an invalid authorization token" do
      let(:payment_method) { create(:credit_card, :external_verified, authorization_token: "test") }
      let(:cassete) { "credit_card_payment_invalid" }

      it { is_expected.to have_http_status(:found) }

      it "set the order as error" do
        expect { subject } .to change { Order.find(order.id).state } .from("pending").to("error")
      end

      it "saves the server response" do
        expect { subject } .to change { Order.find(order.id).raw_response } .from(nil)
      end
    end

    context "with a processed order" do
      let(:cassete) { "processed_order" }
      let(:order) { create(:order, :processed, payment_method: payment_method) }

      it { is_expected.to have_http_status(:found) }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("No se pudo procesar la orden.") }

      it "shows the index page" do
        expect(subject.location).to eq(orders_url)
      end
    end

    context "when fails" do
      before { stub_command("Payments::ProcessOrder", :error) }

      let(:cassete) { "process_order_fails" }

      it { is_expected.to have_http_status(:found) }

      it "shows an error message" do
        subject
        expect(flash[:error]).to be_present
      end
    end

    context "when check issues fails" do
      before { stub_command("Issues::CheckIssues", :error) }

      let(:cassete) { "process_order_check_issues_fails" }

      it { is_expected.to have_http_status(:found) }
      it { expect { subject } .to change { flash[:notice] } .from(nil).to("Orden procesada correctamente, pero con errores al comprobar sus incidencias.") }
    end
  end

  describe "external payment result page" do
    subject(:page) { get :external_payment_result, params: { result: result } }

    let(:result) { "ok" }

    it { is_expected.to have_http_status(:found) }
    it { expect { subject } .to change { flash[:notice] } .from(nil).to("La orden ha sido creada") }

    it "shows the index page" do
      expect(subject.location).to eq(orders_url)
    end

    include_examples "tracks the user visit"

    context "when payment was ko" do
      let(:result) { "ko" }

      it { is_expected.to have_http_status(:found) }
      it { expect { subject } .to change { flash[:error] } .from(nil).to("La orden no ha sido creada") }

      it "shows the index page" do
        expect(subject.location).to eq(orders_url)
      end
    end
  end
end

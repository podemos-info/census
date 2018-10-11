# frozen_string_literal: true

require "rails_helper"

describe OrdersBatchesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  before { pending_order }

  let(:resource_class) { OrdersBatch }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:force_valid_bic) { true }
  let(:orders_batch) { create(:orders_batch) }
  let(:pending_order) { create(:order) }
  let(:current_admin) { create(:admin, :finances) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show, :create, :edit, :new, :update)
  end

  it "handles orders" do
    expect(subject.resource_name).to eq("OrdersBatch")
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
      subject(:page) { get :show, params: { id: orders_batch.id } }

      it { is_expected.to be_successful }
      it { is_expected.to render_template("show") }

      include_examples "tracks the user visit"

      context "with orders with issues" do
        let(:orders_batch) { create(:orders_batch, :with_issues) }

        it { is_expected.to be_successful }
        it { is_expected.to render_template("show") }
      end
    end
  end

  describe "new page" do
    subject { get :new }

    it { is_expected.to be_successful }
    it { is_expected.to render_template("new") }

    include_examples "tracks the user visit"

    context "without pending orders" do
      let(:pending_order) { nil }

      it "alert the user that a new orders batch can't be created" do
        expect { subject } .to change { flash[:alert] } .from(nil).to("No hay órdenes pendientes para incluir en el lote de órdenes")
      end

      it { is_expected.to have_http_status(:found) }
      it { expect(subject.location).to eq(orders_batches_url) }
    end
  end

  describe "create page" do
    subject { put :create, params: { orders_batch: { description: orders_batch.description, orders_from: 1.year.ago, orders_to: Time.zone.today } } }

    let(:orders_batch) { build(:orders_batch) }

    it { expect { subject } .to change(OrdersBatch, :count).by(1) }
    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(orders_batch_url(OrdersBatch.last)) }

    include_examples "tracks the user visit"

    context "when saving fails" do
      before { stub_command("Payments::CreateOrdersBatch", :error) }

      it { is_expected.to be_successful }
      it { expect(subject).to render_template("new") }
      it "shows an error message" do
        expect { subject } .to change { flash[:error] } .from(nil).to("Ha ocurrido un error al guardar el registro.")
      end
    end
  end

  describe "edit page" do
    subject { get :edit, params: { id: orders_batch.id } }

    it { is_expected.to be_successful }
    it { expect(subject).to render_template("edit") }

    include_examples "tracks the user visit"
  end

  describe "charge orders batch" do
    subject(:page) { patch :charge, params: { id: orders_batch.id } }

    it { is_expected.to have_http_status(:found) }
    it { expect(subject.location).to eq(orders_batches_url) }

    include_examples "tracks the user visit"

    it "inform that the orders batch will be processed" do
      expect { subject } .to change { flash[:notice] } .from(nil).to("El lote de órdenes está siendo procesado.")
    end

    context "with created job" do
      subject(:job_record) { Job.last }

      before { page }

      it { is_expected.to be_enqueued }
      it { expect(subject.result).to be_nil }
      it { expect(subject.user).to eq(current_admin) }
    end
  end

  describe "review orders orders batch" do
    subject(:page) { get :review_orders, params: { id: orders_batch.id } }

    it { is_expected.to have_http_status(:found) }

    include_examples "tracks the user visit"

    context "with orders with issues" do
      let(:orders_batch) { create(:orders_batch, :with_issues) }

      it { is_expected.to be_successful }

      context "when submit pending bics" do
        subject(:page) { post :review_orders, params: { id: orders_batch.id, pending_bics: pending_bics } }

        let(:pending_bics) do
          Hash[orders_batch.orders.map do |order|
            next unless order.payment_method.is_a?(PaymentMethods::DirectDebit) && order.payment_method.bic.nil?

            iban_parts = IbanBic.parse(order.payment_method.iban)
            ["#{iban_parts[:country]}_#{iban_parts[:bank]}", "ABCD#{iban_parts[:country]}XX"]
          end .compact]
        end

        it { is_expected.to have_http_status(:found) }
        it { expect(subject.location).to eq(orders_batch_url(orders_batch)) }
      end
    end
  end
end

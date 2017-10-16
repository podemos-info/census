# frozen_string_literal: true

require "rails_helper"

describe OrdersBatchesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }

  before do
    allow(IbanBic).to receive(:calculate_bic).and_return("ABCESXXX") if force_valid_bic
  end

  let(:resource_class) { OrdersBatch }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let(:force_valid_bic) { true }
  let!(:orders_batch) { create(:orders_batch) }
  let!(:pending_order) { create(:order) }

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
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get :show, params: { id: orders_batch.id } }
      it { is_expected.to be_success }
      it { is_expected.to render_template("show") }

      context "with orders that needs review" do
        let(:force_valid_bic) { false }
        it { is_expected.to be_success }
        it { is_expected.to render_template("show") }
      end
    end
  end

  describe "new page" do
    subject { get :new }

    it { expect(subject).to be_success }
    it { expect(subject).to render_template("new") }

    context "without pending orders" do
      let!(:pending_order) { nil }

      it "alert the user that a new orders batch can't be created" do
        subject
        expect(flash[:alert]).to be_present
      end

      it { expect(subject).to have_http_status(:found) }
      it { expect(subject.location).to eq(orders_batches_url) }
    end
  end

  describe "create page" do
    subject { put :create, params: { orders_batch: { description: orders_batch.description, orders_from: 1.year.ago, orders_to: Date.today } } }
    let(:orders_batch) { build(:orders_batch) }
    it { expect { subject } .to change { OrdersBatch.count }.by(1) }
    it { expect(subject).to have_http_status(:found) }
    it { expect(subject.location).to eq(orders_batch_url(OrdersBatch.last)) }
  end

  describe "edit page" do
    subject { get :edit, params: { id: orders_batch.id } }
    it { expect(subject).to be_success }
    it { expect(subject).to render_template("edit") }
  end

  describe "charge orders batch" do
    subject(:page) do
      VCR.use_cassette(cassete) do
        patch :charge, params: { id: orders_batch.id }
      end
    end

    context "without orders that needs review" do
      let(:cassete) { "orders_batch_payment" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "sets the orders batch processed date" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at } .from(nil)
      end
      it "sets the orders batch processed user" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(nil)
      end
      it "sets the orders as processed or error" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:state).uniq } .from(["pending"])
      end
      it "saves the server responses" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:raw_response).uniq } .from([nil])
      end
      it "creates a new download for the orders batch" do
        expect { subject } .to change { Download.count } .by(1)
      end
    end

    context "allows to reprocess reprocessable orders" do
      let(:cassete) { "orders_batch_payment_reprocess" }
      before { Timecop.travel 1.hours.ago { subject } }

      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "sets the orders batch processed date" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at }
      end
      it "sets the orders batch processed user" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by }
      end
      it "creates a new download for the orders batch" do
        expect { subject } .to change { Download.count } .by(1)
      end
    end

    context "with orders that needs review" do
      let(:force_valid_bic) { false }
      let(:cassete) { "orders_batch_payment_review" }

      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows the review orders page" do
        expect(subject.location).to eq(review_orders_orders_batch_url(orders_batch))
      end
    end

    context "without a processor" do
      let(:cassete) { "orders_batch_without_processor" }
      before { override_current_admin(nil) }

      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows an error message" do
        subject
        expect(flash[:error]).to be_present
      end
      it "shows the index page" do
        expect(subject.location).to eq(orders_batches_url)
      end
    end

    context "on errors on generating downloadable file" do
      let!(:orders_batch) { create(:orders_batch, :debit_only) }
      let(:cassete) { "orders_batch_create_download_error" }
      before do
        allow_any_instance_of(Download).to receive(:save).and_return(false)
      end

      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "shows a warning message" do
        subject
        expect(flash[:warning]).to be_present
      end
      it "shows the index page" do
        expect(subject.location).to eq(orders_batches_url)
      end
    end
  end

  describe "review orders orders batch" do
    subject(:page) { get :review_orders, params: { id: orders_batch.id } }

    context "without orders that needs review" do
      it "success" do
        is_expected.to have_http_status(:found)
      end
    end

    context "with orders that needs review" do
      let(:force_valid_bic) { false }

      it { is_expected.to be_success }

      describe "when submit pending bics" do
        subject(:page) { post :review_orders, params: { id: orders_batch.id, pending_bics: pending_bics } }
        let(:pending_bics) do
          Hash[orders_batch.orders.map do |order|
            next unless order.payment_method.is_a?(PaymentMethods::DirectDebit)
            iban_parts = IbanBic.parse(order.payment_method.iban)
            ["#{iban_parts[:country]}_#{iban_parts[:bank]}", "ABCESXXX"]
          end .compact]
        end

        it "success" do
          is_expected.to have_http_status(:found)
        end
        it "shows the index page" do
          expect(subject.location).to eq(orders_batch_url(orders_batch))
        end
      end
    end
  end
end

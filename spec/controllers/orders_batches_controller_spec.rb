# frozen_string_literal: true

require "rails_helper"

describe OrdersBatchesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { OrdersBatch }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:orders_batch) { create(:orders_batch) }
  let(:force_valid_bic) { true }

  before do
    allow(IbanBic).to receive(:calculate_bic).and_return("ABCESXXX") if force_valid_bic
  end

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show, :create, :edit, :new, :update)
  end

  it "handles orders" do
    expect(subject.resource_name).to eq("OrdersBatch")
  end

  it "shows menu" do
    is_expected.to be_include_in_menu
  end

  context "index page" do
    subject(:page) { get :index }
    it { is_expected.to be_success }
    it { is_expected.to render_template("index") }
  end

  with_versioning do
    context "show page" do
      subject(:page) { get :show, params: { id: orders_batch.id } }
      it { is_expected.to be_success }
      it { is_expected.to render_template("show") }
    end
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
    subject(:page) do
      VCR.use_cassette(cassete) do
        patch :review_orders, params: { id: orders_batch.id }
      end
    end

    context "without orders that needs review" do
      let(:cassete) { "orders_batch_review_orders" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
    end
  end
end

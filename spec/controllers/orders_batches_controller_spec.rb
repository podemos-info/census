# frozen_string_literal: true

require "rails_helper"

describe OrdersBatchesController, type: :controller do
  render_views
  include_context "devise login"

  subject(:resource) { all_resources[resource_class] }
  let(:resource_class) { OrdersBatch }
  let(:all_resources) { ActiveAdmin.application.namespaces[:root].resources }
  let!(:orders_batch) { create(:orders_batch) }

  it "defines actions" do
    expect(subject.defined_actions).to contain_exactly(:index, :show)
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

  context "show page" do
    subject(:page) { get :show, params: { id: orders_batch.id } }
    it { is_expected.to be_success }
    it { is_expected.to render_template("show") }
  end

  context "charge orders batch" do
    subject(:page) do
      VCR.use_cassette(cassete) do
        patch :charge, params: { id: orders_batch.id }
      end
    end

    context "with a valid authorization token" do
      let(:cassete) { "orders_batch_payment" }
      it "success" do
        is_expected.to have_http_status(:found)
      end
      it "sets the orders batch as processed" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_at } .from(nil)
      end
      it "sets the orders batch as processed" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).processed_by } .from(nil)
      end
      it "sets the orders as processed or error" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:state).uniq } .from(["pending"])
      end
      it "saves the server responses" do
        expect { subject } .to change { OrdersBatch.find(orders_batch.id).orders.map(&:raw_response).uniq } .from([nil])
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
end

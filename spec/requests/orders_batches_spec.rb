# frozen_string_literal: true

require "rails_helper"

describe "OrdersBatches", type: :request do
  subject(:page) { get orders_batches_path }
  let!(:orders_batch) { create(:orders_batch) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get orders_batches_path(id: orders_batch.id) }
    it { is_expected.to eq(200) }
  end
end

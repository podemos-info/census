# frozen_string_literal: true

require "rails_helper"

describe "OrdersBatches", type: :request do
  include_context "devise login"

  subject(:page) { get orders_batches_path }
  let!(:orders_batch) { create(:orders_batch) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get orders_batches_path(id: orders_batch.id) }
    it { is_expected.to eq(200) }
  end

  with_versioning do
    context "orders batch versions page" do
      before do
        PaperTrail.whodunnit = create(:admin)
        orders_batch.update! description: "#{orders_batch.description} A" # create an orders batch version
      end
      subject { get orders_batch_versions_path(orders_batch_id: orders_batch.id) }
      it { expect(subject).to eq(200) }
    end
  end
end

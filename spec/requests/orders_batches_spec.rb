# frozen_string_literal: true

require "rails_helper"

describe "OrdersBatches", type: :request do
  include_context "with a devise login"

  subject(:page) { get orders_batches_path }

  let!(:orders_batch) { create(:orders_batch) }

  describe "index page" do
    it { is_expected.to eq(200) }
  end

  describe "show page" do
    subject(:page) { get orders_batches_path(id: orders_batch.id) }

    it { is_expected.to eq(200) }
  end

  with_versioning do
    describe "orders batch versions page" do
      subject { get orders_batch_versions_path(orders_batch_id: orders_batch.id) }

      before do
        PaperTrail.request.whodunnit = create(:admin)
        orders_batch.update! description: "#{orders_batch.description} A" # create an orders batch version
      end

      it { expect(subject).to eq(200) }
    end
  end
end

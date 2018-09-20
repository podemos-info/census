# frozen_string_literal: true

require "rails_helper"

describe "Orders", type: :request do
  include_context "devise login"
  let!(:order) { create(:order) }

  describe "index page" do
    subject(:page) { get orders_path(params) }

    let(:params) { {} }

    it { is_expected.to eq(200) }

    context "when ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }

      it { expect(subject).to eq(200) }
    end
  end

  describe "new page" do
    subject(:page) { get new_order_path(order: { person_id: order.person_id }) }

    it { expect(subject).to eq(200) }
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get order_path(id: order.id) }

      it { is_expected.to eq(200) }
    end

    describe "order versions page" do
      subject(:page) { get order_versions_path(order_id: order.id) }

      before do
        PaperTrail.request.whodunnit = create(:admin)
        order.update! description: "#{order.description} A" # create an order version
      end

      it { expect(subject).to eq(200) }
    end
  end
end

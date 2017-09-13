# frozen_string_literal: true

require "rails_helper"

describe "Orders", type: :request do
  subject(:page) { get orders_path }
  let!(:order) { create(:order) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get order_path(id: order.id) }
    it { is_expected.to eq(200) }
  end
end

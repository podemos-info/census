# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::OrdersController, type: :controller do
  subject(:endpoint) { post :create, params: params }

  let(:params) do
    {
      payment_method_type: "existing_payment_method",
      payment_method_id: payment_method.id,
      person_id: person.id,
      description: order.description,
      amount: order.amount,
      campaign_code: order.campaign_code
    }
  end
  let(:person) { create(:person) }
  let(:order) { build(:order) }
  let(:payment_method) { create(:direct_debit) }

  it "is valid" do
    expect(subject).to have_http_status(:created)
    expect(subject.content_type).to eq("application/json")
  end

  context "with an invalid payment method" do
    before do
      payment_method.delete
    end

    it "is not valid" do
      expect(subject).to have_http_status(:unprocessable_entity)
      expect(subject.content_type).to eq("application/json")
    end
  end
end

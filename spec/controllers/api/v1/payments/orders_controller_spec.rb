# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::OrdersController, type: :controller do
  subject(:endpoint) { post :create, params: params }
  let(:params) do
    {
      person_id: person.id,
      description: order.description,
      amount: order.amount,
      campaign_code: order.campaign.campaign_code,
      **payment_method_params
    }
  end
  let(:person) { create(:person) }
  let(:order) { build(:order) }
  let(:payment_method) { create(:direct_debit) }

  describe "with an existing payment method" do
    let(:payment_method_params) do
      {
        payment_method_type: "existing_payment_method",
        payment_method_id: payment_method.id
      }
    end
    it "is valid" do
      is_expected.to have_http_status(:created)
      expect(subject.content_type).to eq("application/json")
    end

    it "responds with a JSON with payment_method_id" do
      expect(JSON.parse(subject.body)) .to have_key("payment_method_id")
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

  describe "for a new credit card payment" do
    let(:payment_method_params) do
      {
        payment_method_type: "credit_card_external",
        return_url: "/test"
      }
    end

    it "is valid" do
      is_expected.to have_http_status(:accepted)
      expect(subject.content_type).to eq("application/json")
    end

    it "responds with a JSON with payment_method_id and form info" do
      expect(JSON.parse(subject.body)) .to have_key("payment_method_id")
      expect(JSON.parse(subject.body)) .to have_key("form")
    end
  end

  describe "for a new direct debit payment" do
    let(:payment_method_params) do
      {
        payment_method_type: "direct_debit",
        iban: IbanBic.random_iban(country: "ES")
      }
    end

    it "is valid" do
      is_expected.to have_http_status(:created)
      expect(subject.content_type).to eq("application/json")
    end

    it "responds with a JSON with payment_method_id" do
      expect(JSON.parse(subject.body)) .to have_key("payment_method_id")
    end
  end
end

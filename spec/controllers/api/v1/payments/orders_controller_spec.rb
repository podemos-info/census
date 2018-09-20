# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::OrdersController, type: :controller do
  describe "Orders creation" do
    subject(:endpoint) { post :create, params: params }

    let(:params) do
      {
        person_id: person.qualified_id_at(:decidim),
        description: order.description,
        amount: order.amount,
        campaign_code: order.campaign.campaign_code,
        **payment_method_params
      }
    end
    let(:person) { create(:person) }
    let(:order) { build(:order) }
    let(:payment_method) { create(:direct_debit) }

    context "with an existing payment method" do
      let(:payment_method_params) do
        {
          payment_method_type: "existing_payment_method",
          payment_method_id: payment_method.id
        }
      end

      it { is_expected.to have_http_status(:created) }
      it { expect(subject.content_type).to eq("application/json") }

      it "responds with a JSON with payment_method_id" do
        expect(JSON.parse(subject.body)) .to have_key("payment_method_id")
      end

      context "with an invalid payment method" do
        before do
          payment_method.delete
        end

        it { expect(subject).to have_http_status(:unprocessable_entity) }
        it { expect(subject.content_type).to eq("application/json") }

        it "returns the errors collection" do
          expect(subject.body).to eq({ payment_method_id: [{ error: "inactive_payment_method" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("Payments::CreateOrder", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end

    describe "for a new credit card payment" do
      let(:payment_method_params) do
        {
          payment_method_type: "credit_card_external",
          return_url: "/test"
        }
      end

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      it "responds with a JSON with payment_method_id and form info" do
        expect(JSON.parse(subject.body).keys) .to match_array(%w(payment_method_id form))
      end
    end

    describe "for a new direct debit payment" do
      let(:payment_method_params) do
        {
          payment_method_type: "direct_debit",
          iban: IbanBic.random_iban(country: "ES")
        }
      end

      it { is_expected.to have_http_status(:created) }
      it { expect(subject.content_type).to eq("application/json") }

      it "responds with a JSON with payment_method_id" do
        expect(JSON.parse(subject.body)) .to have_key("payment_method_id")
      end
    end
  end

  describe "Orders processed total amount for a campaign" do
    subject(:request) { get :total, params: params }

    before { person_order && no_person_order && no_campaign_order && no_person_campaign_order && unprocessed_order && old_order }

    let(:campaign_code) { order.campaign.campaign_code }
    let(:person_id) { order.person.qualified_id_at(:decidim) }
    let(:order) { create(:order, :processed, amount: 1_000_000) }
    let(:person_order) { create(:order, :processed, person: order.person, campaign: order.campaign, amount: 100_000) }
    let(:no_person_order) { create(:order, :processed, campaign: order.campaign, amount: 10_000) }
    let(:no_campaign_order) { create(:order, :processed, person: order.person, amount: 1_000) }
    let(:no_person_campaign_order) { create(:order, :processed, amount: 100) }
    let(:unprocessed_order) { create(:order, campaign: order.campaign, amount: 10) }
    let(:old_order) do
      create(:order, :processed, created_at: 2.years.ago, person: order.person, campaign: order.campaign, amount: 1)
    end

    [
      ["a person", [:person_id], 1_101_001],
      ["a person and a campaign", [:person_id, :campaign_code], 1_100_001],
      ["a campaign", [:campaign_code], 1_110_001],
      ["a person, a campaign and a starting date", [:person_id, :campaign_code, from_date: 1.year.ago], 1_100_000],
      ["a person, a campaign and a starting and ending date", [:person_id, :campaign_code, until_date: 1.year.ago], 1],
      ["every filter", [:person_id, :campaign_code, from_date: 1.year.ago, until_date: 1.month.ago], 0]
    ].each do |desc, test_params, amount|
      context "for #{desc}" do
        let(:params) do
          temp_params = test_params.dup
          res = test_params.last.is_a?(Hash) ? temp_params.pop : {}
          temp_params.each { |param| res[param] = send(param) }
          res
        end

        it { is_expected.to have_http_status(:ok) }
        it { expect(subject.content_type).to eq("application/json") }

        context "with the JSON response" do
          subject(:body) { JSON.parse(request.body) }

          it { is_expected .to have_key("amount") }
          it { expect(body["amount"]) .to eq(amount) }
        end
      end
    end

    context "when has no filter params" do
      let(:params) { {} }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect(subject.content_type).to eq("application/json") }

      it "responds with an empty JSON" do
        expect(subject.body) .to eq("{}")
      end
    end

    context "when only has date filter params" do
      let(:params) { { from_date: 1.year.ago, until_date: 1.month.ago } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect(subject.content_type).to eq("application/json") }

      it "responds with an empty JSON" do
        expect(subject.body) .to eq("{}")
      end
    end
  end
end

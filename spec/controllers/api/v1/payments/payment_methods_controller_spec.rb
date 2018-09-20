# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::PaymentMethodsController, type: :controller do
  before { payment_method }

  let(:payment_method) { create(:credit_card) }

  describe "retrieve person payment methods" do
    subject(:endpoint) { get :index, params: { person_id: person.qualified_id_at(:decidim) } }

    before { payment_method2 && payment_method3 }

    let(:person) { payment_method.person }
    let(:other_person) { create(:person) }
    let(:payment_method2) { create(:direct_debit, person: person) }
    let(:payment_method3) { create(:direct_debit, person: other_person) }

    it { is_expected.to be_successful }

    context "with returned data" do
      subject(:response) { JSON.parse(endpoint.body) }

      it "include both person's payment methods" do
        expect(subject.map { |pm| pm["id"] }).to match_array([payment_method.id, payment_method2.id])
      end

      it "each returned payment method includes only id, name, type, status and verified?" do
        expect(subject.flat_map(&:keys).uniq).to contain_exactly("id", "name", "type", "status", "verified?")
      end
    end
  end

  describe "retrieve a payment method" do
    subject(:endpoint) { get :show, params: { id: payment_method.id } }

    it { is_expected.to be_successful }

    context "with returned data" do
      subject(:response) { JSON.parse(endpoint.body) }

      it "include payment method information" do
        expect(response.keys) .to contain_exactly("id", "name", "type", "status", "verified?")
      end

      it "payment_method is incomplete" do
        expect(response["status"]) .to eq("incomplete")
      end

      it "payment_method is not verified" do
        expect(response["verified?"]) .to be_falsey
      end

      context "when it's verified" do
        let(:payment_method) { create(:credit_card, :external_verified) }

        it "payment_method is incomplete" do
          expect(response["status"]) .to eq("active")
        end

        it "payment_method is not verified" do
          expect(response["verified?"]) .to be_truthy
        end
      end

      context "when it's expired" do
        let(:payment_method) { create(:credit_card, :external_verified, :expired) }

        it "payment_method is incomplete" do
          expect(response["status"]) .to eq("inactive")
        end

        it "payment_method is not verified" do
          expect(response["verified?"]) .to be_truthy
        end
      end
    end
  end
end

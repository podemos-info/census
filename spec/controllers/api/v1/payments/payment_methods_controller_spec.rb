# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::PaymentMethodsController, type: :controller do
  let!(:payment_method) { create(:credit_card) }

  describe "retrieve person payment methods" do
    subject(:endpoint) { get :index, params: { person_id: person.qualified_id_at(:decidim) } }
    let(:person) { payment_method.person }
    let(:other_person) { create(:person) }
    let!(:payment_method2) { create(:direct_debit, person: person) }
    let!(:payment_method3) { create(:direct_debit, person: other_person) }

    it { is_expected.to be_successful }

    context "returned data" do
      subject(:response) { JSON.parse(endpoint.body) }
      it "include both person's payment methods" do
        expect(subject.count).to eq(2)
      end

      it "each returned payment method includes only id, name and type" do
        subject.each do |payment_method_info|
          expect(payment_method_info.keys) .to contain_exactly("id", "name", "type")
          expect([payment_method.id, payment_method2.id]) .to include(payment_method_info["id"])
          expect([payment_method.name, payment_method2.name]) .to include(payment_method_info["name"])
          expect([payment_method.type, payment_method2.type]) .to include(payment_method_info["type"])
        end
      end
    end
  end

  describe "retrieve a payment method" do
    subject(:endpoint) { get :show, params: { id: payment_method.id } }

    it { is_expected.to be_successful }

    context "returned data" do
      subject(:response) { JSON.parse(endpoint.body) }
      it "include payment method information" do
        expect(response.keys) .to contain_exactly("id", "name", "type")
        expect(response["id"]) .to eq(payment_method.id)
        expect(response["name"]) .to eq(payment_method.name)
        expect(response["type"]) .to eq(payment_method.type)
      end
    end
  end
end

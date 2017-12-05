# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::PaymentMethodsController, type: :controller do
  describe "retrieve person payment methods" do
    subject(:endpoint) { get :index, params: { person_id: person.id } }
    let(:person) { create(:person) }
    let!(:payment_method1) { create(:credit_card, person: person) }
    let!(:payment_method2) { create(:direct_debit, person: person) }

    it { is_expected.to be_success }

    context "returned data" do
      subject(:response) { JSON.parse(endpoint.body) }
      it "include both person's payment methods" do
        expect(subject.count).to eq(2)
      end

      it "each returned payment method includes only id, name, type and status" do
        subject.each do |payment_method|
          expect(payment_method.keys).to contain_exactly("id", "name", "type", "status")
        end
      end
    end
  end

  describe "retrieve payment method info" do
    subject(:endpoint) { get :show, params: params }
    let(:params) { { id: payment_method.id } }
    let!(:payment_method) { create(:credit_card) }

    it { is_expected.to be_success }

    context "returned data" do
      subject(:response) { JSON.parse(endpoint.body) }
      it "each returned payment method includes only id, name, type and status" do
        expect(response.keys).to contain_exactly("id", "name", "type", "status")
      end
    end

    context "invalid payment method" do
      let(:params) { { id: 0 } }
      it { is_expected.to be_not_found }
    end
  end
end

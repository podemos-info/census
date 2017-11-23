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

      it "each returned payment method includes only id, name and type" do
        subject.each do |payment_method|
          expect(payment_method.keys) .to contain_exactly("id", "name", "type")
        end
      end
    end
  end
end

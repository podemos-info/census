# frozen_string_literal: true

require "rails_helper"

describe Api::V1::Payments::PaymentMethodsController, type: :controller do
  describe "retrieve person payment methods" do
    subject(:endpoint) { get :index, params: { person_id: person.id } }
    let(:person) { create(:person) }
    let!(:payment_method1) { create(:credit_card, person: person) }
    let!(:payment_method2) { create(:direct_debit, person: person) }

    it { is_expected.to be_success }
    it "returns person payment methods" do
      expect(JSON.parse(subject.body).count) .to eq(2)
    end
  end
end

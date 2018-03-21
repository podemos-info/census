# frozen_string_literal: true

require "rails_helper"

describe "PaymentMethods", type: :request do
  include_context "devise login"
  let!(:payment_method) { create(:direct_debit) }

  context "index page" do
    subject(:page) { get payment_methods_path(params) }
    let(:params) { {} }
    it { expect(subject).to eq(200) }

    context "ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }
      it { expect(subject).to eq(200) }
    end
  end

  with_versioning do
    context "show page" do
      subject(:page) { get payment_method_path(id: payment_method.id) }
      it { is_expected.to eq(200) }
    end

    context "payment method versions page" do
      before do
        PaperTrail.whodunnit = create(:admin)
        payment_method.update! name: "#{payment_method.name} A" # create a payment method version
      end
      subject(:page) { get payment_method_versions_path(payment_method_id: payment_method.id) }
      it { expect(subject).to eq(200) }
    end
  end
end

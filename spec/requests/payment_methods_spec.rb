# frozen_string_literal: true

require "rails_helper"

describe "PaymentMethods", type: :request do
  include_context "with a devise login"
  let!(:payment_method) { create(:direct_debit) }

  describe "index page" do
    subject(:page) { get payment_methods_path(params) }

    let(:params) { {} }

    it { expect(subject).to eq(200) }

    context "when ordered by full_name" do
      let(:params) { { order: "full_name_desc" } }

      it { expect(subject).to eq(200) }
    end
  end

  with_versioning do
    describe "show page" do
      subject(:page) { get payment_method_path(id: payment_method.id) }

      it { is_expected.to eq(200) }
    end

    describe "payment method versions page" do
      subject(:page) { get payment_method_versions_path(payment_method_id: payment_method.id) }

      before do
        PaperTrail.request.whodunnit = create(:admin)
        payment_method.update! name: "#{payment_method.name} A" # create a payment method version
      end

      it { expect(subject).to eq(200) }
    end
  end
end

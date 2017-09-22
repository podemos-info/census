# frozen_string_literal: true

require "rails_helper"

describe "PaymentMethods", type: :request do
  include_context "devise login"

  subject(:page) { get payment_methods_path }
  let!(:payment_method) { create(:direct_debit) }

  context "index page" do
    it { is_expected.to eq(200) }
  end

  context "show page" do
    subject(:page) { get payment_method_path(id: payment_method.id) }
    it { is_expected.to eq(200) }
  end
end

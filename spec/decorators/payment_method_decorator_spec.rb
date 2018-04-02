# frozen_string_literal: true

require "rails_helper"

describe PaymentMethodDecorator do
  subject(:decorator) { payment_method.decorate(context: { current_admin: admin }) }
  let(:payment_method) { build(:direct_debit) }
  let(:admin) { build(:admin) }

  context "#route_key" do
    subject(:method) { decorator.route_key }
    it { is_expected.to eq("payment_methods") }
  end

  context "#singular_route_key" do
    subject(:method) { decorator.singular_route_key }
    it { is_expected.to eq("payment_method") }
  end
end

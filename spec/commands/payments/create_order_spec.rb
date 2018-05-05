# frozen_string_literal: true

require "rails_helper"

describe Payments::CreateOrder do
  subject(:create_order) { described_class.call(form: form, admin: admin) }

  let(:admin) { create(:admin) }
  let(:order) { build(:order) }
  let(:payment_method) { create(:direct_debit, person: order.person) }
  let(:form_class) { Orders::ExistingPaymentMethodOrderForm }
  let(:valid) { true }
  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      description: order.description,
      person: order.person,
      amount: order.amount,
      payment_method: payment_method,
      currency: order.currency,
      campaign: order.campaign
    )
  end

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok, hash_including(:order))
    end

    it "saves the order" do
      expect { subject } .to change { Order.count } .by(1)
    end
  end

  context "when payment method is credit card with external authentication" do
    let(:payment_method) { build(:credit_card, :external, person: order.person) }
    let(:form_class) { Orders::CreditCardExternalOrderForm }

    it "broadcasts :external and the external parameters" do
      expect { subject } .to broadcast(:external, hash_including(:order, :form))
    end

    it "saves the order" do
      expect { subject } .to change { Order.count }
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't save the order" do
      expect { subject } .not_to change { Order.count }
    end
  end

  context "when payment method is inactive" do
    let(:payment_method) { create(:credit_card, :expired, person: order.person) }
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't save the order" do
      expect { subject } .not_to change { Order.count }
    end
  end

  context "when payment method is an authorized credit card" do
    let(:payment_method) { build(:credit_card, :external_verified, person: order.person) }
    let(:form_class) { Orders::CreditCardAuthorizedOrderForm }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok, hash_including(:order))
    end

    it "saves the order" do
      expect { subject } .to change { Order.count } .by(1)
    end
  end

  context "when payment method is a new direct debit" do
    let(:payment_method) { build(:direct_debit, person: order.person) }
    let(:form_class) { Orders::DirectDebitOrderForm }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok, hash_including(:order))
    end

    it "saves the order" do
      expect { subject } .to change { Order.count } .by(1)
    end
  end

  context "unexpected fails scenario" do
    context "when payment method is invalid" do
      before { stub_command("Payments::SavePaymentMethod", :invalid) }

      it "broadcasts :invalid" do
        expect { subject } .to broadcast(:invalid)
      end

      it "doesn't save the order" do
        expect { subject } .not_to change { Order.count }
      end
    end

    context "when payment method save fails" do
      before { stub_command("Payments::SavePaymentMethod", :error) }

      it "broadcasts :error" do
        expect { subject } .to broadcast(:error)
      end

      it "doesn't save the order" do
        expect { subject } .not_to change { Order.count }
      end
    end

    context "when order save fails" do
      before { allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::Rollback) }

      it "broadcasts :error" do
        expect { subject } .to broadcast(:error)
      end

      it "doesn't save the order" do
        expect { subject } .not_to change { Order.count }
      end
    end
  end
end

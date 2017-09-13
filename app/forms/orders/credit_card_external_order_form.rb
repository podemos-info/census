# frozen_string_literal: true

# The form object that handles the data for an order with an existing payment method
module Orders
  class CreditCardExternalOrderForm < OrderForm
    attribute :return_url, String
    validates :return_url, presence: true

    def payment_method
      PaymentMethods::CreditCard.new(
        person: person,
        return_url: return_url,
        processor: Settings.payments.processors.credit_card
      )
    end
  end
end

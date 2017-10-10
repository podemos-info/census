# frozen_string_literal: true

# The form object that handles the data for an order with credit card payment that is going to be externally authorized
module Orders
  class CreditCardExternalOrderForm < OrderForm
    attribute :return_url, String
    validates :return_url, presence: true

    def payment_method
      PaymentMethods::CreditCard.new(
        person: person,
        return_url: return_url,
        payment_processor: Settings.payments.default_processors.credit_card
      )
    end
  end
end

# frozen_string_literal: true

# The form object that handles the data for an order with an existing payment method
module Orders
  class CreditCardAuthorizedOrderForm < OrderForm
    attribute :authorization_token, String
    attribute :expiration_year, String
    attribute :expiration_month, String
    validates :authorization_token, :expiration_year, :expiration_month, presence: true

    def payment_method
      PaymentMethods::CreditCard.new(
        person: person,
        authorization_token: authorization_token,
        expiration_year: expiration_year,
        expiration_month: expiration_month,
        processor: Settings.payments.processors.credit_card,
        verified: true
      )
    end
  end
end
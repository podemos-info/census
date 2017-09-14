# frozen_string_literal: true

# The form object that handles the data for an order with direct debit payment
module Orders
  class DirectDebitOrderForm < OrderForm
    attribute :iban, String
    validates :iban, presence: true
    validates_with SEPA::IBANValidator, field_name: :iban

    def payment_method
      PaymentMethods::DirectDebit.new(
        person: person,
        iban: iban,
        processor: Settings.payments.processors.direct_debit
      )
    end
  end
end

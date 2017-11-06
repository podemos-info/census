# frozen_string_literal: true

module PaymentMethods
  class BankTransfer < PaymentMethod
    store_accessor :information, :iban
    additional_information :iban, :bic

    def external_authorization?
      false
    end

    def name_info
      { iban_last_digits: iban[-4..-1] }
    end

    def bic
      IbanBic.calculate_bic(iban)
    end
  end
end

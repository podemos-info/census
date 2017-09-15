# frozen_string_literal: true

module PaymentMethods
  class DirectDebit < PaymentMethod
    store_accessor :information, :iban, :bic

    def processable?(order)
      order.orders_batch.present? # DirectDebit can only be processed in batches
    end

    def external_authorization?
      false
    end

    def name_info
      { iban_last_digits: iban[-4..-1] }
    end
  end
end

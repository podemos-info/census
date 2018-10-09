# frozen_string_literal: true

module PaymentMethods
  class DirectDebit < PaymentMethod
    store_accessor :information, :country, :bank_code

    additional_information :iban, :bic

    before_validation :set_payment_processor

    normalize :iban, with: [:clean, :upcase]

    def possible_issues
      [Issues::Payments::MissingBic]
    end

    def processable?(args = {})
      args[:inside_batch?]
    end

    def reprocessable?
      true
    end

    def external_authorization?
      false
    end

    def name_info
      { iban_last_digits: iban[-4..-1] }
    end

    def bic
      @bic ||= IbanBic.calculate_bic(iban)
    end

    def iban_parts
      @iban_parts ||= IbanBic.parse(iban)
    end

    def iban
      indifferent_sensible_data[:iban]
    end

    def iban=(value)
      self.sensible_data = { iban: value }
      @bic = @iban_parts = nil
      self.information = { country: iban_parts&.fetch(:country, nil), bank_code: iban_parts&.fetch(:bank, nil) }
    end

    private

    def set_payment_processor
      self.payment_processor ||= Settings.payments.default_processors.direct_debit
    end

    def indifferent_sensible_data
      sensible_data&.with_indifferent_access || {}
    end
  end
end

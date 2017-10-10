# frozen_string_literal: true

module PaymentMethods
  class DirectDebit < PaymentMethod
    store_accessor :information, :iban
    additional_information :iban, :bic

    before_save :check_missing_bic

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
      IbanBic.calculate_bic(iban)
    end

    def check_missing_bic
      if !admin_issues && !bic
        self.admin_issues = true
      elsif admin_issues && !response_code && bic
        self.admin_issues = false
      end
    end

    def needs_review?(_args = {})
      check_missing_bic
      save
      super
    end

    def status_message
      return I18n.t("census.payment_methods.status_messages.no_bic") unless bic
      super
    end
  end
end

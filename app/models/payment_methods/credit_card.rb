# frozen_string_literal: true

module PaymentMethods
  class CreditCard < PaymentMethod
    store_accessor :information, :authorization_token, :expiration_year, :expiration_month
    attr_accessor :card_number, :ccv, :return_url

    def processable?(_order)
      authorized? && active?
    end

    def external_authorization?
      !card_number.present?
    end

    def active?
      super && !expired?
    end

    def authorized?
      authorization_token.present?
    end

    def expired?
      Date.today < expires_at
    end

    def expires_at
      Date.civil(expiration_year, expiration_month, 1) + 1.month
    end

    def issues_fixed?
      false
    end
  end
end

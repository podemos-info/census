# frozen_string_literal: true

module PaymentMethods
  class CreditCard < PaymentMethod
    store_accessor :information, :authorization_token, :expiration_year, :expiration_month
    additional_information :authorization_token, :expiration_year, :expiration_month
    attr_accessor :return_url
    before_validation :set_payment_processor

    def processable?(_args = {})
      authorized? && active?
    end

    def external_authorization?
      !authorized?
    end

    def user_visible?
      verified?
    end

    def active?
      super && !expired?
    end

    def authorized?
      authorization_token.present?
    end

    def expired?
      expires_at && Date.today > expires_at
    end

    def expires_at
      return nil unless expiration_year && expiration_month
      @expires_at ||= Date.civil(expiration_year.to_i, expiration_month.to_i, 1) + 1.month
    end

    def name_info
      if authorization_token
        { expiration: "#{expiration_month.to_s.rjust(2, "0")}/#{expiration_year}" }
      else
        { expiration: I18n.t("census.payment_methods.incomplete") }
      end
    end

    private

    def set_payment_processor
      self.payment_processor ||= Settings.payments.default_processors.credit_card
    end
  end
end

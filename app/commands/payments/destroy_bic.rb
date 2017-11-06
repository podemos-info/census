# frozen_string_literal: true

module Payments
  # A command to destroy a BIC
  class DestroyBic < Rectify::Command
    # Public: Initializes the command.
    #
    # bic - A bic object to destroy.
    # admin - The admin user creating the bic.
    def initialize(bic:, admin:)
      @bic = bic
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the bic couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless bic

      result = Bic.transaction do
        @bic.destroy!
        IbanBic.clear_cache # force clear IbanBic cache before commit
        Issues::CheckPaymentMethodIssues.call(payment_method: payment_method, admin: admin)

        :ok
      end
      broadcast(result || :invalid)
    end

    private

    attr_reader :bic, :admin

    def payment_method
      @payment_method ||= ::PaymentMethodsForBank.for_parts(country: bic.country, bank: bic.bank_code).first
    end
  end
end

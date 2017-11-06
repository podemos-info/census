# frozen_string_literal: true

module Payments
  # A command to save a payment method
  class SavePaymentMethod < Rectify::Command
    # Public: Initializes the command.
    #
    # payment_method - A payment_method to be saved.
    def initialize(payment_method:, admin:)
      @payment_method = payment_method
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the order couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless payment_method.valid?

      result = PaymentMethod.transaction do
        payment_method.save!
        Issues::CheckPaymentMethodIssues.call(payment_method: payment_method, admin: admin)
        :ok
      end
      broadcast(result || :invalid)
    end

    private

    attr_reader :payment_method, :admin
  end
end

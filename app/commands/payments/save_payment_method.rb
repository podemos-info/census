# frozen_string_literal: true

module Payments
  # A command to save a payment method
  class SavePaymentMethod < Rectify::Command
    # Public: Initializes the command.
    #
    # payment_method - A payment_method to be saved.
    def initialize(payment_method:, admin: nil)
      @payment_method = payment_method
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok. Includes the saved payment method.
    # - :invalid when the payment method data is invalid.
    # - :error if the payment method couldn't be saved.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless payment_method&.valid?
      return broadcast(:error) unless payment_method.save

      broadcast(:ok, payment_method: payment_method)

      CheckPaymentMethodIssuesJob.perform_later(payment_method: payment_method, admin: admin)
    end

    private

    attr_reader :payment_method, :admin
  end
end

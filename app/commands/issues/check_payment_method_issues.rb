# frozen_string_literal: true

module Issues
  # A command to create, update or fix issues for payment methods
  class CheckPaymentMethodIssues < Rectify::Command
    # Public: Initializes the command.
    #
    # payment_method - The payment method to check
    # admin - The admin user triggered the check
    def initialize(payment_method:, admin:)
      @payment_method = payment_method
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when there is no issues with the payment method.
    # - :invalid if the issue couldn't be created.
    # - :new_issue if there is a new issue with this document.
    # - :existing_issue if there already was a non fixed issue with this document.
    #
    # Returns nothing.
    def call
      Issues::CheckDirectDebitPaymentMethodIssues.call(payment_method: payment_method, admin: admin) if payment_method.is_a?(PaymentMethods::DirectDebit)

      broadcast(:ok)
    end

    private

    attr_reader :payment_method, :admin
  end
end

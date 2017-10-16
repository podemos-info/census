# frozen_string_literal: true

module Payments
  # A command to dismiss issues payment method
  class DismissPaymentMethodIssues < Rectify::Command
    # Public: Initializes the command.
    #
    # payment_method - Payment method to update
    # issues_type - Type of issues to dismiss
    def initialize(payment_method, issues_type)
      @payment_method = payment_method
      @issues_type = issues_type
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the payment method couldn't be updated.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @payment_method && @issues_type && %w(user_issues admin_issues system_issues).member?(@issues_type.to_s)

      @payment_method.send("#{@issues_type}=", false)

      broadcast(@payment_method.save ? :ok : :invalid)
    end
  end
end

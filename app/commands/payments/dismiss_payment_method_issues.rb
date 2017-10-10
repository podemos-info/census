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
      return broadcast(:invalid) unless @payment_method && @issues_type

      case issues_type
      when :user
        @payment_method.user_issues = false
      when :admin
        @payment_method.admin_issues = false
      when :system
        @payment_method.system_issues = false
      end

      broadcast(@payment_method.save ? :ok : :invalid)
    end
  end
end

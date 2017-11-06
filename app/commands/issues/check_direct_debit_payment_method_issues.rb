# frozen_string_literal: true

module Issues
  # A command to create, update or fix issues for direct debit payment methods
  class CheckDirectDebitPaymentMethodIssues < CheckIssues
    # Public: Initializes the command.
    #
    # payment_method - The payment method to check
    # admin - The admin user triggered the check.
    def initialize(payment_method:, admin:)
      @payment_method = payment_method
      @admin = admin
    end

    private

    def has_issue?
      payment_method.bic.nil?
    end

    def issue
      @issue ||= ::IssuesForBank.for(country: country, bank_code: bank_code).merge(::IssuesNonFixed.for).first || Issue.new(
        issue_type: :missing_bic,
        role: Admin.roles[:finances],
        level: :medium,
        assigned_to: nil,
        information: {
          country: country,
          bank_code: bank_code,
          iban: iban
        },
        fixed_at: nil
      )
    end

    attr_reader :payment_method, :admin

    def update_affected_objects
      issue.payment_methods = payment_methods
    end

    def payment_methods
      @payment_methods ||= ::PaymentMethodsForBank.for(iban: @iban)
    end

    def country
      @country ||= iban_parts[:country]
    end

    def bank_code
      @bank_code ||= iban_parts[:bank]
    end

    def iban_parts
      @iban_parts ||= IbanBic.parse(iban)
    end

    def iban
      @iban ||= payment_method.iban
    end
  end
end

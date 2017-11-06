# frozen_string_literal: true

module Payments
  # A command to create a BIC
  class CreateBic < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The admin user creating the bic.
    def initialize(form:, admin:)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the bic couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form.valid?

      result = Bic.transaction do
        bic_record.save!
        if current_issue
          IbanBic.clear_cache # force clear IbanBic cache before commit
          Issues::CheckPaymentMethodIssues.call(payment_method: payment_method_with_issue, admin: admin)
        end

        :ok
      end
      broadcast(result || :invalid, bic_record)
    end

    private

    attr_reader :form, :admin

    def bic_record
      @bic_record ||= Bic.new(country: form.country, bank_code: form.bank_code, bic: form.bic)
    end

    def payment_method_with_issue
      @payment_method ||= ::PaymentMethodsForBank.for(iban: current_issue.information["iban"]).first
    end

    def current_issue
      @current_issue ||= ::IssuesForBank.for(country: form.country, bank_code: form.bank_code).merge(::IssuesNonFixed.for).first
    end
  end
end

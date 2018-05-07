# frozen_string_literal: true

class CheckBicIssuesJob < ApplicationJob
  include ::IssuesChecker

  queue_as :payments

  def perform(country:, bank_code:, admin:)
    @country = country
    @bank_code = bank_code
    return unless payment_method

    Issues::CheckIssues.call(issuable: payment_method, admin: admin, &log_issues_message)
  end

  private

  def payment_method
    @payment_method ||= ::PaymentMethodsForBank.for_parts(country: @country, bank: @bank_code).first
  end
end

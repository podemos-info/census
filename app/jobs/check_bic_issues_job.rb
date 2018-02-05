# frozen_string_literal: true

class CheckBicIssuesJob < ApplicationJob
  queue_as :finances

  def related_objects
    @country = arguments.first&.fetch(:country, nil)
    @bank_code = arguments.first&.fetch(:bank_code, nil)
    [
      payment_method
    ]
  end

  def perform(country:, bank_code:, admin:)
    @country = country
    @bank_code = bank_code
    Issues::CheckPaymentMethodIssues.call(payment_method: payment_method, admin: admin)
  end

  private

  def payment_method
    @payment_method ||= ::PaymentMethodsForBank.for_parts(country: @country, bank: @bank_code).first
  end
end

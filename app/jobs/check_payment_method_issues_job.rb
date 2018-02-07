# frozen_string_literal: true

class CheckPaymentMethodIssuesJob < ApplicationJob
  include ::IssuesChecker
  queue_as :finances

  def related_objects
    [
      arguments.first&.fetch(:payment_method, nil)
    ]
  end

  def perform(payment_method:, admin:)
    Issues::CheckPaymentMethodIssues.call(payment_method: payment_method, admin: admin, &log_issues_message)
  end
end

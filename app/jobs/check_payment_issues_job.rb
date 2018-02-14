# frozen_string_literal: true

class CheckPaymentIssuesJob < ApplicationJob
  include ::IssuesChecker

  queue_as :payments

  def related_objects
    [
      arguments.first&.fetch(:issuable, nil)
    ]
  end

  def perform(issuable:, admin:)
    Issues::CheckIssues.call(issuable: issuable, admin: admin, &log_issues_message)
  end
end

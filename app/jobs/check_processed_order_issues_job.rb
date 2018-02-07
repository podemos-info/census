# frozen_string_literal: true

class CheckProcessedOrderIssuesJob < ApplicationJob
  include ::IssuesChecker
  queue_as :finances

  def related_objects
    [
      arguments.first&.fetch(:order, nil)
    ]
  end

  def perform(order:, admin:)
    Issues::CheckProcessedOrderIssues.call(order: order, admin: admin, &log_issues_message)
  end
end

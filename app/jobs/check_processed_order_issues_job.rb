# frozen_string_literal: true

class CheckProcessedOrderIssuesJob < ApplicationJob
  queue_as :finances

  def related_objects
    [
      arguments.first&.fetch(:order, nil)
    ]
  end

  def perform(order:, admin:)
    Issues::CheckProcessedOrderIssues.call(order: order, admin: admin)
  end
end

# frozen_string_literal: true

class CheckPersonIssuesJob < ApplicationJob
  include ::IssuesChecker
  queue_as :lopd

  def related_objects
    [
      arguments.first&.fetch(:person, nil)
    ]
  end

  def perform(person:, admin:)
    Issues::CheckPersonIssues.call(person: person, admin: admin, &log_issues_message)
  end
end

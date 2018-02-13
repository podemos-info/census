# frozen_string_literal: true

class UpdateProcedureJob < ApplicationJob
  include ::IssuesChecker

  queue_as :procedures

  def related_objects
    [
      arguments.first&.fetch(:procedure, nil)
    ]
  end

  def perform(procedure:, admin:)
    Issues::CheckIssues.call(issuable: procedure, admin: admin, &log_issues_message)
  end
end

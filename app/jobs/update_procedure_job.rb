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

    return unless procedure.auto_acceptable? && !procedure.has_issues? && !procedure.person.has_issues?

    form = Procedures::ProcessForm.from_params(procedure: procedure, admin: admin, event: "accept", comment: nil)
    Procedures::ProcessProcedure.call(form) do
      on(:invalid) { log :user, key: "auto_accept.invalid" }
      on(:error) { log :user, key: "auto_accept.error" }
    end
  end
end

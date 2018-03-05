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

    return unless procedure.auto_processable?

    event = procedure.issues_summary == :ok ? "accept" : "reject"
    form = Procedures::ProcessForm.from_params(procedure: procedure, admin: admin, event: event, comment: "AUTO")
    Procedures::ProcessProcedure.call(form) do
      on(:invalid) { log :user, key: "auto_process.invalid" }
      on(:error) { log :user, key: "auto_process.error" }
    end
  end
end

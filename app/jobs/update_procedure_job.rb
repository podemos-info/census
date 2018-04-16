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
    # Update issues before auto processing
    Issues::CheckIssues.call(issuable: procedure, admin: admin, &log_issues_message)

    action = procedure_action(procedure)
    return unless action

    form = Procedures::ProcessProcedureForm.from_params(procedure: procedure, processed_by: admin, action: action, comment: "AUTO")
    Procedures::ProcessProcedure.call(form: form, admin: admin) do
      on(:invalid) { log :user, key: "auto_process.invalid" }
      on(:error) { log :user, key: "auto_process.error" }
    end

    # Update issues after auto processing
    Issues::CheckIssues.call(issuable: procedure, admin: admin, &log_issues_message)
  end

  private

  def procedure_action(procedure)
    if procedure.person.discarded?
      "dismiss"
    elsif procedure.auto_processable? && procedure.issues_summary == :ok
      "accept"
    end
  end
end

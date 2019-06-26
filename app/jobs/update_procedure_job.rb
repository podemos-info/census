# frozen_string_literal: true

class UpdateProcedureJob < ApplicationJob
  include ::IssuesChecker

  queue_as :procedures

  def related_objects
    [
      arguments.first&.fetch(:procedure, nil)
    ].compact
  end

  def perform(procedure:, admin:, location: {})
    update_person_location(procedure, location) if location.present?

    update_issues(procedure, admin)

    action = procedure_action(procedure)
    return unless action

    auto_process(action, procedure, admin)

    update_related_procedures_issues(procedure, admin)
  end

  private

  def update_person_location(procedure, location)
    People::UpdatePersonLocation.call(person: procedure.person, location: location) do
      on(:ok) do |info|
        procedure.update(person_location_id: info[:current_location].id) if info[:current_location]
      end
      on(:invalid) { log :user, key: "update_person_location.invalid" }
      on(:error) { log :user, key: "update_person_location.error" }
    end
  end

  def update_issues(procedure, admin)
    Issues::CheckIssues.call(issuable: procedure, admin: admin, &log_issues_message)
  end

  def auto_process(action, procedure, admin)
    form = Procedures::ProcessProcedureForm.from_params(procedure: procedure,
                                                        processed_by: admin,
                                                        action: action)

    Procedures::ProcessProcedure.call(form: form, admin: admin) do
      on(:invalid) { log :user, key: "auto_process.invalid" }
      on(:error) { log :user, key: "auto_process.error" }
    end
  end

  def update_related_procedures_issues(procedure, admin)
    related_procedures(procedure).each do |related_procedure|
      Issues::CheckIssues.call(issuable: related_procedure, admin: admin, &log_issues_message)
    end
  end

  def procedure_action(procedure)
    return unless procedure.pending?

    if procedure.person.discarded?
      "dismiss"
    elsif procedure.auto_processable? && procedure.issues_summary == :ok
      "accept"
    end
  end

  def related_procedures(procedure)
    [procedure] + procedure.person.procedures.pending + procedure.person.open_issues.flat_map(&:procedures)
  end
end

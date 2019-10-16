# frozen_string_literal: true

class UpdateProcedureJob < ApplicationJob
  include ::IssuesChecker

  queue_as :procedures

  def related_objects
    [
      arguments.first&.fetch(:procedure, nil)
    ].compact
  end

  def perform(procedure:, admin:, location: nil)
    update_person_location(procedure, location) if location.present?

    update_issues(procedure, admin)

    auto_process_params = prepare_auto_process(procedure)

    return unless auto_process_params

    auto_process(auto_process_params, procedure, admin)

    update_related_procedures_issues(procedure, admin)
  end

  private

  def update_person_location(procedure, location)
    People::UpdatePersonLocation.call(form: People::PersonLocationForm.from_params(location)) do
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

  def auto_process(auto_process_params, procedure, admin)
    form = Procedures::ProcessProcedureForm.from_params(procedure: procedure,
                                                        processed_by: admin,
                                                        lock_version: procedure.lock_version,
                                                        **auto_process_params)

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

  def prepare_auto_process(procedure)
    procedure.reload

    return unless procedure.pending?

    if procedure.person.discarded?
      { action: "dismiss", comment: "discarded_person" }
    elsif procedure.auto_processable? && procedure.issues_summary == :ok
      { action: "accept", comment: "auto_accepted" }
    end
  end

  def related_procedures(procedure)
    [procedure] + procedure.person.procedures.pending + procedure.person.open_issues.flat_map(&:procedures)
  end
end

# frozen_string_literal: true

module Procedures
  # A command to process a procedure.
  class ProcessProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The person that will process the procedure.
    def initialize(form:, admin:)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem updating the procedure.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?
      return broadcast(:busy) if busy?

      add_issue_or_process_procedure

      broadcast result, procedure: procedure

      procedure_triggers if result == :ok
    end

    private

    attr_accessor :form, :admin, :result
    delegate :procedure, to: :form

    def busy?
      procedure.processing_by && procedure.processing_by != admin
    end

    def add_issue_or_process_procedure
      if form.adding_issue?
        add_issue
      else
        process_procedure_transaction
      end
    end

    def add_issue
      issue = Issues::People::AdminRemark.for(procedure, find: false)
      issue.explanation = form.comment
      issue.fill
      self.result = :issue_error
      Issues::CreateIssue.call(issue: issue, admin: admin) do
        on(:invalid) { self.result = :invalid }
        on(:error) {}
        on(:ok) { self.result = :issue_ok }
      end
    end

    def process_procedure_transaction
      Procedure.transaction do
        self.result = process_procedure
        raise ActiveRecord::Rollback unless result == :ok
      end
    end

    def process_procedure
      procedure.processing_by = nil
      procedure.processed_by = admin
      procedure.processed_at = Time.current
      procedure.lock_version = form.lock_version
      procedure.comment = form.comment
      procedure.send(form.action)

      procedure.save ? :ok : :error
    rescue ActiveRecord::StaleObjectError
      procedure.reload
      :conflict
    end

    def procedure_triggers
      ProceduresChannel.notify_status(procedure)
      PersonPendingProcedures.for(procedure.person).each do |procedure|
        ::UpdateProcedureJob.perform_later(procedure: procedure,
                                           admin: admin)
      end
    end
  end
end

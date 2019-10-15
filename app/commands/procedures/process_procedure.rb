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

      result = if form.adding_issue?
                 add_issue
               else
                 process_procedure
               end

      broadcast result, procedure: procedure

      if result == :ok
        PersonPendingProcedures.for(procedure.person).each do |procedure|
          ::UpdateProcedureJob.perform_later(procedure: procedure,
                                             admin: admin)
        end
      end
    end

    private

    attr_accessor :form, :admin
    delegate :procedure, to: :form

    def add_issue
      issue = Issues::People::AdminRemark.for(procedure, find: false)
      issue.explanation = form.comment
      issue.fill
      ret = :issue_error
      Issues::CreateIssue.call(issue: issue, admin: admin) do
        on(:invalid) { ret = :invalid }
        on(:error) {}
        on(:ok) { ret = :issue_ok }
      end
      ret
    end

    def process_procedure
      procedure.processing_by = nil
      procedure.processed_by = admin
      procedure.processed_at = Time.current
      procedure.lock_version = form.lock_version
      procedure.comment = form.comment
      procedure.send(form.action)

      procedure.save ? :ok : :error
    end
  end
end

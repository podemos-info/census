# frozen_string_literal: true

module Procedures
  # A command to process a procedure.
  class ProcessProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The person that is undoing the procedure.
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

      if form.adding_issue?
        add_issue
      else
        process_procedure
      end

      broadcast result, procedure: form.procedure
    end

    private

    attr_accessor :form, :admin, :result

    def add_issue
      issue = Issues::People::AdminRemark.for(form.procedure, find: false)
      issue.explanation = form.comment
      issue.fill
      ret = :issue_error
      Issues::CreateIssue.call(issue: issue, admin: admin) do
        on(:invalid) { ret = :invalid }
        on(:error) {}
        on(:ok) { ret = :issue_ok }
      end
      @result = ret
    end

    def process_procedure
      @result = :error
      Procedure.transaction do
        process form.procedure
        @result = :ok
      end
    end

    def process(current_procedure)
      current_procedure.processed_by = admin
      current_procedure.processed_at = Time.current
      current_procedure.comment = form.comment
      current_procedure.send(form.action)

      if current_procedure.invalid?
        @result = :invalid
        raise ActiveRecord::Rollback
      end

      current_procedure.save!
    end
  end
end

# frozen_string_literal: true

module Procedures
  # A command to process a procedure.
  class ProcessProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
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

      process_procedure

      broadcast result, procedure: form.procedure
    end

    private

    attr_accessor :form, :result

    def process_procedure
      @result = :error
      Procedure.transaction do
        process form.procedure
        @result = :ok
      end
    end

    def process(current_procedure)
      current_procedure.processed_by = form.admin
      current_procedure.processed_at = Time.current
      current_procedure.comment = form.comment
      current_procedure.send(form.event)

      current_procedure.dependent_procedures.each do |child_procedure|
        process child_procedure
      end

      if current_procedure.invalid?
        @result = :invalid
        raise ActiveRecord::Rollback
      end

      current_procedure.save!
    end
  end
end

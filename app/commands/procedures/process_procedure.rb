# frozen_string_literal: true

module Procedures
  # A command to process a procedure.
  class ProcessProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # procedure - A Procedure object.
    # processed_by - The person that is processing the procedure
    # params - The event that will be processed and the comment for the procedure
    def initialize(procedure, processed_by, params = {})
      @procedure = procedure
      @processed_by = processed_by
      @params = params
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @procedure && @processed_by && safe_event

      process_procedure

      broadcast result, procedure: @procedure
    end

    private

    attr_accessor :result

    def process_procedure
      @result = :error
      Procedure.transaction do
        process @procedure
        @result = :ok
      end
    end

    def process(current_procedure)
      current_procedure.processed_by = @processed_by
      current_procedure.processed_at = Time.current
      current_procedure.comment = @params[:comment]
      current_procedure.send(safe_event)

      current_procedure.dependent_procedures.each do |child_procedure|
        process child_procedure
      end

      if current_procedure.invalid?
        @result = :invalid
        raise ActiveRecord::Rollback
      end

      current_procedure.save!
    end

    def safe_event
      @safe_event ||= ((@procedure.permitted_events(@processed_by) - [:undo]) & [@params[:event]&.to_sym]).first
    end
  end
end

# frozen_string_literal: true

module Procedures
  # A command to undo the last process of a procedure.
  class UndoProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # procedure - A Procedure object.
    # processed_by - The person that is undoing the procedure
    def initialize(procedure, processed_by)
      @procedure = procedure
      @processed_by = processed_by
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @procedure && @processed_by && @procedure.full_undoable_by?(@processed_by)

      result = Procedure.transaction do
        undo_procedure @procedure
        :ok
      end

      broadcast result || :invalid
    end

    private

    def undo_procedure(current_procedure)
      current_procedure.dependent_procedures.each do |child_procedure|
        undo_procedure child_procedure
      end

      current_procedure.undo
      current_procedure.processed_by = current_procedure.undo_version.processed_by
      current_procedure.processed_at = current_procedure.undo_version.processed_at
      current_procedure.comment = current_procedure.undo_version.comment

      raise ActiveRecord::Rollback unless current_procedure.valid?

      current_procedure.save!
    end
  end
end

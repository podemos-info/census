# frozen_string_literal: true

module Procedures
  # A command to undo the last process of a procedure.
  class UndoProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # procedure - A Procedure object.
    # admin - The person that is undoing the procedure
    def initialize(procedure:, admin:)
      @procedure = procedure
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
      return broadcast(:invalid) unless admin && procedure&.undoable_by?(admin)

      undo_procedure

      broadcast result, procedure: procedure
    end

    private

    attr_accessor :procedure, :admin, :result

    def undo_procedure
      @result = :error
      Procedure.transaction do
        undo procedure
        @result = :ok
      end
    end

    def undo(current_procedure)
      current_procedure.undo
      current_procedure.processed_by = current_procedure.undo_version.processed_by
      current_procedure.processed_at = current_procedure.undo_version.processed_at
      current_procedure.comment = current_procedure.undo_version.comment
      current_procedure.save!
    end
  end
end

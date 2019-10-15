# frozen_string_literal: true

module Procedures
  # A command to undo the last process of a procedure.
  class UndoProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The person that is undoing the procedure
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
      return broadcast(:invalid) unless form&.valid? && admin && procedure&.undoable_by?(admin)

      result = undo_procedure

      broadcast result, procedure: procedure

      ProceduresChannel.notify_status(procedure) if result == :ok
    end

    private

    attr_accessor :form, :admin
    delegate :procedure, to: :form

    def undo_procedure
      procedure.undo
      procedure.processed_by = procedure.undo_version.processed_by
      procedure.processed_at = procedure.undo_version.processed_at
      procedure.lock_version = procedure.lock_version
      procedure.comment = procedure.undo_version.comment
      procedure.save ? :ok : :error
    rescue ActiveRecord::StaleObjectError
      procedure.reload
      :conflict
    end
  end
end

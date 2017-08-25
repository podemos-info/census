# frozen_string_literal: true

# A command to undo the last process of a procedure.
class UndoProcedure < Rectify::Command
  # Public: Initializes the command.
  #
  # procedure - A Procedure object.
  # processor - The person that is undoing the procedure
  def initialize(procedure, processor)
    @procedure = procedure
    @processor = processor
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the procedure wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) unless @procedure && @processor

    result = Procedure.transaction do
      undo_procedure @procedure
      :ok
    end

    broadcast result || :invalid
  end

  private

  def undo_procedure(current_procedure)
    raise ActiveRecord::Rollback unless current_procedure.undoable?(@processor)

    current_procedure.dependent_procedures.each do |child_procedure|
      undo_procedure child_procedure
    end

    current_procedure.state = current_procedure.undo_version.state
    current_procedure.processed_by = current_procedure.undo_version.processed_by
    current_procedure.processed_at = current_procedure.undo_version.processed_at
    current_procedure.comment = current_procedure.undo_version.comment
    current_procedure.undo

    raise ActiveRecord::Rollback unless current_procedure.valid?

    current_procedure.save!
  end
end

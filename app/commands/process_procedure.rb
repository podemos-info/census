# frozen_string_literal: true

# A command to process a procedure.
class ProcessProcedure < Rectify::Command
  # Public: Initializes the command.
  #
  # procedure - A Procedure object.
  # event - The event that will be processed
  # processor - The person that is processing the procedure
  def initialize(procedure, event, processor)
    @procedure = procedure
    @processor = processor
    @event = event
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the procedure wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    @procedure.processed_by = @processor
    @procedure.processed_at = Time.current
    @procedure.send(@event)

    return broadcast(:invalid) unless @procedure.valid?

    @procedure.save!

    broadcast(:ok)
  end
end

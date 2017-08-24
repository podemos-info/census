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
    if safe_event
      result = Procedure.transaction do
        process_procedure @procedure
        :ok
      end
    end

    broadcast result || :invalid
  end

  private

  def process_procedure(current_procedure)
    current_procedure.processed_by = @processor
    current_procedure.processed_at = Time.current
    current_procedure.send(safe_event)

    raise ActiveRecord::Rollback unless current_procedure.valid?

    current_procedure.save!

    current_procedure.dependent_procedures.each do |child_procedure|
      process_procedure child_procedure
    end
  end

  def safe_event
    @safe_event ||= ((@procedure.aasm.events(permitted: true).map(&:name) - [:undo]) & [@event.to_sym]).first
  end
end

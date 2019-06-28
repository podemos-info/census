# frozen_string_literal: true

module People
  # A command to cancel a person account.
  class CreateCancellation < PersonCommand
    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem updating the record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_cancellation

      broadcast result, cancellation: cancellation

      if result == :ok
        ::UpdateProcedureJob.perform_later(procedure: cancellation,
                                           admin: admin,
                                           location: location)
      end
    end

    private

    def save_cancellation
      cancellation.save ? :ok : :error
    end

    attr_reader :form, :admin

    def cancellation
      @cancellation ||= procedure_for(form.person, ::Procedures::Cancellation) do |procedure|
        procedure.channel = form.channel
        procedure.reason = form.reason
      end
    end
  end
end

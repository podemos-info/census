# frozen_string_literal: true

module People
  # A command to cancel a person account.
  class CreateCancellation < PersonCommand
    # Public: Initializes the command.
    # form - A form object with the params.
    # admin - The admin user creating the person.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

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

      ::UpdateProcedureJob.perform_later(procedure: cancellation, admin: admin) if result == :ok
    end

    private

    def save_cancellation
      cancellation.save ? :ok : :error
    end

    attr_reader :form, :admin

    def cancellation
      @cancellation ||= procedure_for(form.person, ::Procedures::Cancellation) do |procedure|
        procedure.reason = form.reason
      end
    end
  end
end

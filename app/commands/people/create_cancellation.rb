# frozen_string_literal: true

module People
  # A command to cancel a person account.
  class CreateCancellation < Rectify::Command
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
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      result = save_cancellation || :error

      broadcast result, cancellation: cancellation

      ::UpdateProcedureJob.perform_later(procedure: cancellation, admin: admin) if result == :ok
    end

    private

    def save_cancellation
      :ok if cancellation.save
    end

    attr_reader :form, :admin

    def cancellation
      @cancellation ||= ::Procedures::Cancellation.new(
        person: form.person,
        reason: form.reason
      )
    end
  end
end

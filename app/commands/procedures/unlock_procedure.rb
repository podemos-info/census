# frozen_string_literal: true

module Procedures
  # A command to unlock a procedure without processing it.
  class UnlockProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The person that was processing the procedure.
    def initialize(form:, admin:)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem unlocking the procedure.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid? && admin
      return broadcast(:noop) unless procedure.processing_by == admin

      result = unlock_procedure

      broadcast result, procedure: procedure
    end

    private

    attr_accessor :form, :admin
    delegate :procedure, :lock_version, to: :form

    def unlock_procedure
      procedure.lock_version = lock_version
      procedure.processing_by = nil
      procedure.save(touch: false) ? :ok : :error
    rescue ActiveRecord::StaleObjectError
      procedure.reload
      :conflict
    end
  end
end

# frozen_string_literal: true

module Procedures
  # A command to lock a procedure to work with it.
  class LockProcedure < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The person that is processing the procedure.
    def initialize(form:, admin:)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid.
    # - :error if there is any problem locking the procedure.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid? && admin
      return broadcast(:noop) if mine?
      return broadcast(:busy) if busy?

      result = lock_procedure
      broadcast result, procedure: procedure
    end

    private

    attr_accessor :form, :admin
    delegate :procedure, :force?, :lock_version, to: :form

    def busy?
      !force? && procedure.processing_by && !mine?
    end

    def mine?
      procedure.processing_by == admin
    end

    def lock_procedure
      procedure.lock_version = lock_version
      procedure.processing_by = admin
      procedure.save(touch: false) ? :ok : :error
    rescue ActiveRecord::StaleObjectError
      procedure.reload
      :conflict
    end
  end
end

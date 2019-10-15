# frozen_string_literal: true

# The form object that handles the locking and unlocking of a procedure
module Procedures
  class LockProcedureForm < Form
    attribute :procedure
    attribute :force, Boolean
    attribute :lock_version, Integer

    validates :procedure, presence: true

    def force?
      @force
    end
  end
end

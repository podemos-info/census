# frozen_string_literal: true

# The form object that handles the processing of a procedure
module Procedures
  class LockProcedureForm < Form
    attribute :procedure
    attribute :force, Boolean

    validates :procedure, presence: true

    def force?
      @force
    end
  end
end

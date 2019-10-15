# frozen_string_literal: true

# The form object that handles the processing of a procedure
module Procedures
  class UndoProcedureForm < Form
    mimic :procedure

    attribute :procedure
    attribute :lock_version, Integer

    validates :procedure, :lock_version, presence: true

    def lock_version
      @lock_version || procedure&.lock_version
    end
  end
end

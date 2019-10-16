# frozen_string_literal: true

# The form object that handles the processing of a procedure
module Procedures
  class ProcessProcedureForm < Form
    mimic :procedure

    attribute :procedure
    attribute :processed_by
    attribute :action, String
    attribute :comment, String
    attribute :lock_version, Integer

    validates :procedure, :action, :lock_version, presence: true
    validates :comment, presence: true, unless: :accepting?
    validate :validate_event

    def accepting?
      action == "accept"
    end

    def adding_issue?
      action == "issue"
    end

    def validate_event
      if action == "undo"
        errors.add(:action, :cant_process_undo_event)
      elsif !(adding_issue? || procedure.permitted_event?(action, processed_by))
        errors.add(:action, :not_permitted_event)
      end
    end

    def lock_version
      @lock_version || procedure&.lock_version
    end
  end
end

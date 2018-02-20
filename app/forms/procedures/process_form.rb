# frozen_string_literal: true

# The form object that handles the processing of a procedure
module Procedures
  class ProcessForm < Form
    mimic :procedure

    attribute :procedure
    attribute :admin
    attribute :event, String
    attribute :comment, String

    validates :procedure, presence: true
    validates :event, presence: true
    validates :comment, presence: true, unless: :accepting?
    validate :processable?

    def accepting?
      event == "accept"
    end

    def processable?
      if event == "undo"
        errors.add(:event, :cant_process_undo_event)
      elsif !procedure.permited_event?(event, admin)
        errors.add(:event, :not_permitted_event)
      end
    end
  end
end

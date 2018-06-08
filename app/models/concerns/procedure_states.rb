# frozen_string_literal: true

module ProcedureStates
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :pending, initial: true
      state :accepted, before_enter: :process_accept, after_enter: :persist_changes!,
                       before_exit: :undo_accept, after_exit: :persist_changes!
      state :rejected, before_enter: :process_reject, after_enter: :persist_changes!,
                       before_exit: :undo_reject, after_exit: :persist_changes!
      state :dismissed

      event :accept do
        transitions from: :pending, to: :accepted, if: :acceptable?
      end

      event :reject do
        transitions from: :pending, to: :rejected
      end

      event :dismiss do
        transitions from: :pending, to: :dismissed
      end

      event :undo do
        transitions from: [:accepted, :rejected], to: :pending, if: :undoable?
      end
    end

    def processed?
      accepted? || rejected?
    end

    def auto_processed?
      processed? && processed_by.nil?
    end

    def undoable?
      processed_at && processed_at > Settings.procedures.undo_minutes.minutes.ago && undo_version.present?
    end

    def undoable_by?(processor)
      processor == processed_by && undoable?
    end

    def undo_version
      @undo_version = versions.last.reify(dup: true) unless defined?(@undo_version) && versions.last&.object&.fetch("state") == state
      @undo_version
    end

    def permitted_events(processor)
      @permitted_events ||= aasm.events(permitted: true).map do |event|
        event.name if permitted_event?(event.name, processor)
      end .compact
    end

    def permitted_event?(event, processor)
      case event.to_s
      when "accept" then full_acceptable_by?(processor)
      when "undo" then full_undoable_by?(processor)
      else
        true
      end
    end

    def full_acceptable_by?(processor)
      return false unless processor&.person_id != person_id && acceptable?
      process_accept
      ret = dependent_procedures.all? do |dependent_procedure|
        dependent_procedure.person = person # synchronize child person status with parent person
        dependent_procedure.full_acceptable_by? processor
      end
      undo_accept
      ret
    end

    def full_undoable_by?(processor)
      undoable_by?(processor) && dependent_procedures.all? { |dependent_procedure| dependent_procedure.full_undoable_by? processor }
    end
  end
end

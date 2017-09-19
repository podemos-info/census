# frozen_string_literal: true

module ProcedureStates
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :pending, initial: true
      state :accepted, before_enter: :process_accept, after_enter: :persist_accept_changes!,
                       before_exit: :undo_accept, after_exit: :persist_accept_changes!
      state :issues, :rejected

      event :accept do
        transitions from: [:pending, :issues], to: :accepted, if: :acceptable?
      end

      event :set_issues do
        transitions from: :pending, to: :issues
      end

      event :reject do
        transitions from: [:pending, :issues], to: :rejected
      end

      event :undo do
        transitions from: [:accepted, :rejected], to: :pending, if: :undoable?
      end
    end

    def processed?
      accepted? || rejected?
    end

    def processable?
      !processed?
    end

    def undoable?
      processed_at && processed_at > Settings.misc.undo_minutes.minutes.ago && undo_version.present?
    end

    def undoable_by?(processor)
      processor == processed_by && undoable?
    end

    def undo_version
      defined?(@undo_version) ||
        versions.reverse.each do |version|
          previous_version = version.reify
          if previous_version&.state && previous_version&.state != state
            @undo_version = previous_version
            break
          end
        end
      @undo_version
    end

    def permitted_events(processor)
      @permitted_events ||= aasm.events(permitted: true).map do |event|
        event.name unless (event == :accept && !full_acceptable_by?(processor)) || (event == :undo && !full_undoable_by(processor))
      end .compact
    end

    def full_acceptable_by?(processor)
      return false unless processor.present? && processor != person && acceptable?
      process_accept
      ret = dependent_procedures.all? do |dependent_procedure|
        dependent_procedure.person = person # use the same person instance
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

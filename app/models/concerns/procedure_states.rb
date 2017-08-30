# frozen_string_literal: true

require "active_support/concern"

module ProcedureStates
  extend ActiveSupport::Concern

  included do
    include AASM

    # === START overridable methods
    def process_accept; end

    def undo_accept; end

    def persist_accept_changes!; end

    def acceptable?
      true
    end
    # === END overridable methods

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

    def initialize(*args)
      raise "Cannot directly instantiate a Procedure" if self.class == Procedure
      super
    end

    def processed?
      accepted? || rejected?
    end

    def processable?
      !processed?
    end

    def undoable?
      processed_at && processed_at > Settings.undo_minutes.minutes.ago && undo_version.present?
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

    def permitted_events
      @permitted_events ||= aasm.events(permitted: true).map(&:name)
    end

    def full_acceptable?
      return false unless acceptable?
      process_accept
      ret = dependent_procedures.all? do |dependent_procedure|
        dependent_procedure.person = person # use the same person instance
        dependent_procedure.full_acceptable?
      end
      undo_accept
      ret
    end

    def full_undoable_by?(processor)
      undoable_by?(processor) && dependent_procedures.all? { |dependent_procedure| dependent_procedure.full_undoable_by? processor }
    end
  end
end
# frozen_string_literal: true

module PersonStates
  extend ActiveSupport::Concern

  included do
    enum state: [:pending, :enabled, :cancelled, :trashed]

    aasm :state, column: "state", enum: true do
      state :pending, initial: true
      state :enabled, :cancelled, :trashed

      event :accept do
        transitions from: :pending, to: :enabled
      end

      event :undo do
        transitions from: [:enabled, :trashed], to: :pending
      end

      event :cancel do
        transitions from: [:pending, :enabled], to: :cancelled
      end

      event :trash do
        transitions from: [:pending, :enabled], to: :trashed
      end
    end

    def self.state_names
      @state_names ||= aasm(:state).states.map(&:name).map(&:to_s)
    end
  end
end

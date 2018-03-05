# frozen_string_literal: true

module PersonStates
  extend ActiveSupport::Concern

  included do
    enum state: [:pending, :rejected, :enabled]

    aasm column: "state", enum: true do
      state :pending, initial: true
      state :rejected, :enabled

      event :register do
        transitions from: :pending, to: :enabled
      end

      event :reject do
        transitions from: :pending, to: :rejected
      end

      event :undo do
        transitions from: [:enabled, :rejected], to: :pending
      end

      event :prepare do
        transitions from: [:pending, :rejected], to: :pending
      end
    end

    def self.state_names
      @state_names ||= aasm.states.map(&:name).map(&:to_s)
    end

    def can_register?
      aasm.events(permitted: true).map(&:name).include? :register
    end
  end
end

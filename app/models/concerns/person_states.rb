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

      event :cancel, before: :ensure_discarded do
        transitions from: [:pending, :enabled], to: :cancelled
      end

      event :trash, before: :ensure_discarded do
        transitions from: [:pending, :enabled], to: :trashed
      end
    end

    private

    def ensure_discarded
      self.discarded_at ||= Time.zone.now
    end
  end
end

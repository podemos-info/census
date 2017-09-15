# frozen_string_literal: true

module OrderStates
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :pending, initial: true
      state :processed, :returned, :error

      event :charge do
        transitions from: :pending, to: :processed
      end

      event :fail do
        transitions from: :pending, to: :error
      end

      event :return do
        transitions from: :processed, to: :returned
      end
    end
  end
end

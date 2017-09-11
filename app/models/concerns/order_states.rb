# frozen_string_literal: true

module OrderStates
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :pending, initial: true
      state :ok, :returned, :error

      event :accept do
        transitions from: :pending, to: :ok
      end

      event :fail do
        transitions from: :pending, to: :error
      end

      event :return do
        transitions from: :ok, to: :returned
      end
    end
  end
end

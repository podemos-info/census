# frozen_string_literal: true

module PersonVerifications
  extend ActiveSupport::Concern

  included do
    enum verification: [:not_verified, :verification_requested, :verified, :mistake, :fraudulent]

    aasm :verification, column: "verification", enum: true do
      state :not_verified, initial: true
      state :verification_requested, :verified, :mistake, :fraudulent

      event :request_verification do
        transitions from: :not_verified, to: :verification_requested
      end

      event :verify do
        transitions from: [:not_verified, :verification_requested], to: :verified
      end

      event :undo_verification do
        transitions from: :verified, to: :not_verified
      end

      event :fraud_detected do
        transitions from: [:not_verified, :verification_requested, :verified], to: :fraudulent
      end

      event :mistake_detected do
        transitions from: [:not_verified, :verification_requested, :verified], to: :mistake
      end
    end

    def self.verification_names
      @verification_names ||= aasm(:verification).states.map(&:name).map(&:to_s)
    end
  end
end

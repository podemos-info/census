# frozen_string_literal: true

module PersonVerifications
  extend ActiveSupport::Concern

  included do
    enum verification: [:not_verified, :verification_requested, :verification_received, :verified, :mistake, :fraudulent]

    aasm :verification, column: "verification", enum: true do
      state :not_verified, initial: true
      state :verification_requested, :verification_received, :verified, :mistake, :fraudulent

      event :request_verification do
        transitions from: [:not_verified, :verification_received], to: :verification_requested, guard: :kept?
      end

      event :receive_verification do
        transitions from: [:not_verified, :verification_requested], to: :verification_received, guard: :kept?
      end

      event :verify do
        transitions from: [:not_verified, :verification_requested, :verification_received], to: :verified, guard: :kept?
      end

      event :undo_verification do
        transitions from: :verified, to: :verification_received
      end

      event :fraud_detected, before: :ensure_trashed do
        transitions from: [:not_verified, :verification_requested, :verification_received, :verified], to: :fraudulent
      end

      event :mistake_detected, before: :ensure_trashed do
        transitions from: [:not_verified, :verification_requested, :verification_received, :verified], to: :mistake
      end

      event :unverify do
        transitions from: :verified, to: :not_verified
      end
    end

    private

    def ensure_trashed
      trash if may_trash?
    end
  end
end

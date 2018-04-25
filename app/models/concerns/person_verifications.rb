# frozen_string_literal: true

module PersonVerifications
  extend ActiveSupport::Concern

  included do
    enum verification: [:not_verified, :verification_requested, :verified, :mistake, :fraudulent]

    aasm :verification, column: "verification", enum: true do
      state :not_verified, initial: true
      state :verification_requested, :verified, :mistake, :fraudulent

      event :request_verification do
        transitions from: :not_verified, to: :verification_requested, guard: :kept?
      end

      event :verify do
        transitions from: [:not_verified, :verification_requested], to: :verified, guard: :kept?
      end

      event :undo_verification do
        transitions from: :verified, to: :not_verified
      end

      event :fraud_detected, before: :ensure_trashed do
        transitions from: [:not_verified, :verification_requested, :verified], to: :fraudulent
      end

      event :mistake_detected, before: :ensure_trashed do
        transitions from: [:not_verified, :verification_requested, :verified], to: :mistake
      end
    end

    private

    def ensure_trashed
      trash if may_trash?
    end
  end
end

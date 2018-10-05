# frozen_string_literal: true

module PersonPhoneVerifications
  extend ActiveSupport::Concern

  included do
    enum phone_verification: [:not_verified, :verified, :reassigned], _prefix: :phone

    aasm :phone_verification, column: "phone_verification", enum: true, namespace: :phone do
      state :not_verified, initial: true
      state :verified, :reassigned

      event :verify do
        transitions from: [:not_verified, :reassigned, :verified], to: :verified, guard: :kept?
      end

      event :unverify do
        transitions from: [:not_verified, :verified], to: :not_verified
      end

      event :reassign do
        transitions from: :verified, to: :reassigned
      end
    end
  end
end

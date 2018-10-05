# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class ConfirmPhoneVerificationForm < PhoneVerificationForm
    mimic :phone_verification

    attribute :received_code, String

    validate :check_received_code

    def check_received_code
      errors.add :received_code, :invalid if person && !otp.verify_with_drift(received_code, Settings.people.phone_verification.expires_after)
    end
  end
end

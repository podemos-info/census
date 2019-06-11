# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PhoneVerificationForm < Form
    include ::HasPerson

    mimic "Procedures::PhoneVerification"

    attribute :phone, String

    def phone
      @phone.presence || person&.phone
    end

    def otp_code
      @otp_code ||= otp.now
    end

    def otp
      ROTP::TOTP.new(otp_secret, digits: Settings.people.phone_verification.otp_length)
    end

    private

    def otp_secret
      Base32.encode("#{Rails.application.secrets.secret_key_base}#{phone}#{person.created_at}")
    end
  end
end

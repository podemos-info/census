# frozen_string_literal: true

module People
  # A command to send an OTP code to a person.
  class StartPhoneVerification < PersonCommand
    # Public: Initializes the command.
    # form - A form object with the params.
    # admin - The admin user requesting the send of the OTP
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the given information wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new records.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?
      return broadcast(:error) unless send_token

      broadcast(:ok)
    end

    private

    attr_reader :form, :admin

    def send_token
      People::SmsSender.send_message(form.phone, message)
    end

    def message
      I18n.t("census.people.start_phone_verification.sms_message", otp_code: form.otp_code)
    end
  end
end

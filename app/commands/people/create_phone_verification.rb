# frozen_string_literal: true

module People
  # A command to create a phone verification procedure for a person.
  class CreatePhoneVerification < PersonCommand
    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_phone_verification

      broadcast result, phone_verification: phone_verification

      if result == :ok
        ::UpdateProcedureJob.perform_now(procedure: phone_verification,
                                         admin: admin,
                                         location: location)
      end
    end

    private

    def save_phone_verification
      phone_verification.save ? :ok : :error
    end

    attr_reader :form, :admin
    delegate :person, to: :form

    def phone_verification
      @phone_verification ||= begin
        procedure_for(person, ::Procedures::PhoneVerification) do |procedure|
          procedure.phone = form.phone
        end
      end
    end
  end
end

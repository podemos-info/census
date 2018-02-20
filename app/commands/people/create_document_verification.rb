# frozen_string_literal: true

module People
  # A command to create a change of membership for a person.
  class CreateDocumentVerification < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_verification || :error

      broadcast result, verification: verification

      ::UpdateProcedureJob.perform_later(procedure: verification, admin: admin) if result == :ok
    end

    private

    def save_verification
      :ok if verification.save
    end

    attr_reader :form, :admin

    def verification
      @verification ||= begin
        ret = ::Procedures::DocumentVerification.new(
          person: form.person
        )
        form.files.each do |file|
          ret.attachments.build(file: file)
        end
        ret
      end
    end
  end
end

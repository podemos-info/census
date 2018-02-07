# frozen_string_literal: true

module Procedures
  # A command to create a change of membership for a person.
  class CreateVerification < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      broadcast create_procedure || :error, procedure: verification
    end

    private

    attr_reader :form

    def verification
      @verification ||= begin
        ret = ::Procedures::VerificationDocument.new(
          person: form.person
        )
        form.files.each do |file|
          ret.attachments.build(file: file)
        end
        ret
      end
    end

    def create_procedure
      :ok if verification.save
    end
  end
end

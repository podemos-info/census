# frozen_string_literal: true

module People
  # A command to request a verification to a person.
  class RequestVerification < PersonCommand
    # Public: Initializes the command.
    # person - The person that should be verified.
    # admin - The admin user requesting the verification.
    def initialize(person:, admin: nil)
      @person = person
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new records.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless person&.may_request_verification?
      return broadcast(:error) unless person.request_verification!

      broadcast(:ok, person: person)
    end

    private

    attr_reader :person, :admin
  end
end

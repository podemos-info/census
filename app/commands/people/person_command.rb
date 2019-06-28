# frozen_string_literal: true

module People
  # A base command for a person.
  class PersonCommand < Rectify::Command
    # Public: Initializes the command.
    # form - A form object with the params.
    # admin - The admin user executing the command
    def initialize(form:, admin: nil, location: {})
      @form = form
      @admin = admin
      @location = location
    end

    attr_accessor :location

    def procedure_for(person, procedure_type)
      procedure = procedure_type.pending.find_or_initialize_by(person: person)
      procedure.state = :pending
      yield procedure
      procedure
    end
  end
end

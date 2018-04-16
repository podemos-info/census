# frozen_string_literal: true

module People
  # A base command for a person.
  class PersonCommand < Rectify::Command
    def procedure_for(person, procedure_type)
      procedure = procedure_type.pending.find_or_initialize_by(person: person)
      procedure.state = nil
      yield procedure
      procedure
    end
  end
end

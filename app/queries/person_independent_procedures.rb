# frozen_string_literal: true

class PersonIndependentProcedures < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.procedures.independent
  end
end

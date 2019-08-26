# frozen_string_literal: true

class PersonLastProcedures < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    PersonProcedures.for(@person).order(created_at: :desc).limit(3)
  end
end

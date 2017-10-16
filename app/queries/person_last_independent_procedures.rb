# frozen_string_literal: true

class PersonLastIndependentProcedures < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    PersonIndependentProcedures.for(@person).order(created_at: :desc).limit(3)
  end
end

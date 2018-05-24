# frozen_string_literal: true

class PersonPendingProcedures < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.procedures.pending.order(created_at: :desc)
  end
end

# frozen_string_literal: true

class PersonCountLocations < Rectify::Query
  def self.for(person)
    new(person).value
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.person_locations
  end

  def value
    query.count
  end
end

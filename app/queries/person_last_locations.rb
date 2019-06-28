# frozen_string_literal: true

class PersonLastLocations < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.person_locations.order(created_at: :desc).limit(5)
  end
end

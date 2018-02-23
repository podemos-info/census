# frozen_string_literal: true

class PeopleEnabled < Rectify::Query
  def self.for
    new.query
  end

  def query
    Person.enabled
  end
end

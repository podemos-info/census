# frozen_string_literal: true

class PeopleByBornDate < Rectify::Query
  def self.for(born_at)
    new(born_at).query
  end

  def initialize(born_at)
    @born_at = born_at
  end

  def query
    Person.where(born_at: @born_at)
  end
end

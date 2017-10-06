# frozen_string_literal: true

class PersonLastOrders < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.orders.order(created_at: :desc).limit(3)
  end
end

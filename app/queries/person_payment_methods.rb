# frozen_string_literal: true

class PersonPaymentMethods < Rectify::Query
  def self.for(person)
    new(person).query
  end

  def initialize(person)
    @person = person
  end

  def query
    @person.payment_methods.order(created_at: :desc)
  end
end

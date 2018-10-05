# frozen_string_literal: true

class PeopleByVerifiedPhone < Rectify::Query
  def self.for(phone)
    new(phone).query
  end

  def initialize(phone)
    @phone = phone
  end

  def query
    Person.phone_verified.where(phone: @phone)
  end
end

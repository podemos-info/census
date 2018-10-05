# frozen_string_literal: true

class PeopleWithoutVerifiedPhoneByUsedPhone < Rectify::Query
  def self.for(phone)
    new(phone).query
  end

  def initialize(phone)
    @phone = phone
  end

  def query
    Person.phone_not_verified.joins(:procedures).merge(Procedures::PhoneVerification.accepted.where("information ->> 'phone' = ?", @phone))
  end
end
